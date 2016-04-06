module SparkPostRails
  class DeliveryMethod
    require 'net/http'

    attr_accessor :settings, :data, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      @data = {content: {}}

      sparkpost_data = find_sparkpost_data_from mail

      prepare_recipients_from mail
      prepare_from_address_from mail
      prepare_reply_to_address_from mail

      prepare_subject_from mail
      prepare_cc_headers_from mail
      prepare_content_from mail
      prepare_attachments_from mail

      prepare_options_from sparkpost_data
      prepare_headers

      result = post_to_api

      process_result result
    end

  private
    def find_sparkpost_data_from mail
      if mail[:sparkpost_data]
        eval(mail[:sparkpost_data].value)
      else
        Hash.new
      end
    end

    def prepare_recipients_from mail
      @data[:recipients] = prepare_addresses(mail.to, mail[:to].display_names)
      if !mail.cc.nil?
        @data[:recipients] += prepare_copy_addresses(mail.cc, mail[:cc].display_names, mail.to.first).flatten
      end
      if !mail.bcc.nil?
        @data[:recipients] += prepare_copy_addresses(mail.bcc, mail[:bcc].display_names, mail.to.first).flatten
      end
    end

    def prepare_addresses emails, names
      emails = [emails] unless emails.is_a?(Array)
      emails.each_with_index.map {|email, index| prepare_address(email, index, names) }
    end

    def prepare_address email, index, names
      if !names[index].nil?
        { address:  { email: email, name: names[index] } }
      else
        { address: { email: email } }
      end
    end

    def prepare_copy_addresses emails, names, header_to
      emails = [emails] unless emails.is_a?(Array)
      emails.each_with_index.map {|email, index| prepare_copy_address(email, index, names, header_to) }
    end

    def prepare_copy_address email, index, names, header_to
      if !names[index].nil? && !header_to.nil?
        { address:  { email: email, name: names[index], header_to: header_to } }
      elsif !names[index].nil?
        { address:  { email: email, name: names[index] } }
      elsif !header_to.nil?
        { address: { email: email, header_to: header_to } }
      else
        { address: { email: email } }
      end
    end

    def prepare_from_address_from mail
      if !mail[:from].display_names.first.nil?
        from = { email: mail.from.first, name: mail[:from].display_names.first }
      else
        from = { email: mail.from.first }
      end

      @data[:content][:from] = from
    end

    def prepare_reply_to_address_from mail
      unless mail.reply_to.nil?
        @data[:content][:reply_to] = mail.reply_to.first
      end
    end

    def prepare_subject_from mail
      @data[:content][:subject] = mail.subject
    end

    def prepare_cc_headers_from mail
      if !mail[:cc].nil?
        copies = prepare_addresses(mail.cc, mail[:cc].display_names)
        emails = []
        copies.each do |copy|
          emails << copy[:address][:email]
        end
        @data[:content][:headers] = { cc: emails }
      end
    end

    def prepare_content_from mail
      if mail.multipart?
        if mail.html_part
          @data[:content][:html] = cleanse_encoding(mail.html_part.body.to_s)
        end

        if mail.text_part
          @data[:content][:text] = cleanse_encoding(mail.text_part.body.to_s)
        end
      else
        @data[:content][:text] = cleanse_encoding(mail.body.to_s)
      end
    end

    def cleanse_encoding content
      ::JSON.parse({c: content}.to_json)["c"]
    end

    def prepare_attachments_from mail
      attachments = Array.new
      inline_images = Array.new

      mail.attachments.each do |attachment|
        #We decode and reencode here to ensure that attachments are 
        #Base64 encoded without line breaks as required by the API.
        attachment_data = { name: attachment.filename,
                            type: attachment.content_type,
                            data: Base64.encode64(attachment.body.decoded).gsub("\n","") }

        if attachment.inline?
          inline_images << attachment_data
        else
          attachments << attachment_data
        end
      end

      if attachments.count > 0
        @data[:content][:attachments] = attachments
      end

      if inline_images.count > 0
        @data[:content][:inline_images] = inline_images
      end
    end

    def prepare_options_from sparkpost_data
      @data[:options] = {
        :open_tracking => SparkPostRails.configuration.track_opens,
        :click_tracking => SparkPostRails.configuration.track_clicks
      }

      unless SparkPostRails.configuration.campaign_id.nil?
        @data[:campaign_id] = SparkPostRails.configuration.campaign_id
      end

      unless SparkPostRails.configuration.return_path.nil?
        @data[:return_path] = SparkPostRails.configuration.return_path
      end

      prepare_sandbox_mode_from sparkpost_data
    end

    def prepare_sandbox_mode_from sparkpost_data
      if SparkPostRails.configuration.sandbox
        @data[:options][:sandbox] = true
      end

      if sparkpost_data.has_key?(:sandbox)
        if sparkpost_data[:sandbox]
          @data[:options][:sandbox] = sparkpost_data[:sandbox]
        else
          @data[:options].delete(:sandbox)
        end
      end
    end

    def prepare_headers
      @headers = {
        "Authorization" => SparkPostRails.configuration.api_key,
        "Content-Type"  => "application/json"
      }
    end

    def post_to_api
      url = "https://api.sparkpost.com/api/v1/transmissions"

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, @headers)
      request.body = JSON.generate(@data)

      http.request(request)
    end

    def process_result result
      result_data = JSON.parse(result.body)

      if result_data["errors"]
        @response = result_data["errors"]
        raise SparkPostRails::DeliveryException, @response
      else
        @response = result_data["results"]
      end
    end
  end
end
