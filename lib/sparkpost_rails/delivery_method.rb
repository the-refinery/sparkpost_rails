module SparkPostRails
  class DeliveryMethod
    require 'net/http'

    attr_accessor :settings, :data, :response, :headers

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      @data = {content: {}}

      sparkpost_data = find_sparkpost_data_from mail

      prepare_recipients_from mail, sparkpost_data
      prepare_recipients_data_from sparkpost_data

      if sparkpost_data.has_key?(:template_id)
        prepare_template_content_from sparkpost_data
      else
        prepare_from_address_from mail
        prepare_reply_to_address_from mail

        prepare_subject_from mail
        prepare_cc_headers_from mail, sparkpost_data
        prepare_inline_content_from mail, sparkpost_data
        prepare_attachments_from mail
      end

      prepare_substitution_data_from sparkpost_data
      prepare_metadata_from sparkpost_data
      prepare_description_from sparkpost_data
      prepare_options_from mail, sparkpost_data
      prepare_additional_mail_headers_from mail

      prepare_api_headers_from sparkpost_data

      result = post_to_api

      process_result result
    end

  private
    def find_sparkpost_data_from mail
      mail.sparkpost_data
    end

    def prepare_recipients_from mail, sparkpost_data
      if sparkpost_data.has_key?(:recipient_list_id)
        @data[:recipients] = {list_id: sparkpost_data[:recipient_list_id]}
      else
        @data[:recipients] = prepare_addresses(mail.to, mail[:to].display_names)

        if !mail.cc.nil?
          @data[:recipients] += prepare_copy_addresses(mail.cc, mail[:cc].display_names, mail.to.first).flatten
        end

        if !mail.bcc.nil?
          @data[:recipients] += prepare_copy_addresses(mail.bcc, mail[:bcc].display_names, mail.to.first).flatten
        end
      end

    end

    def prepare_addresses emails, names
      emails = [emails] unless emails.is_a?(Array)
      header_to = emails.join(",")
      emails.each_with_index.map {|email, index| prepare_address(email, index, names, header_to) }
    end

    def prepare_address email, index, names, header_to
      if !names[index].nil?
        { address:  { email: email, name: names[index], header_to: header_to } }
      else
        { address: { email: email, header_to: header_to } }
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

    # See https://developers.sparkpost.com/api/#/introduction/substitutions-reference/links-and-substitution-expressions-within-substitution-values
    def prepare_recipients_data_from sparkpost_data
      if (recipients_data = sparkpost_data[:recipients])
        @data[:recipients].each_with_index do |recipient, index|
          if (recipient_data = recipients_data[index])
            recipient.merge!(recipient_data)
          end
        end
      end
    end

    def prepare_template_content_from sparkpost_data
      @data[:content][:template_id] = sparkpost_data[:template_id]

    end

    def prepare_substitution_data_from sparkpost_data
      if sparkpost_data[:substitution_data]
        @data[:substitution_data] = sparkpost_data[:substitution_data]
      end
    end

    def prepare_metadata_from sparkpost_data
      if sparkpost_data[:metadata]
        @data[:metadata] = sparkpost_data[:metadata]
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

    def prepare_cc_headers_from mail, sparkpost_data
      if !mail[:cc].nil? && !sparkpost_data.has_key?(:recipient_list_id)
        copies = prepare_addresses(mail.cc, mail[:cc].display_names)
        emails = []

        copies.each do |copy|
          emails << copy[:address][:email]
        end

        @data[:content][:headers] = { cc: emails.join(",") }
      end
    end

    def prepare_inline_content_from mail, sparkpost_data
      if mail.multipart?
        if mail.html_part
          @data[:content][:html] = cleanse_encoding(mail.html_part.body.to_s)
        end

        if mail.text_part
          @data[:content][:text] = cleanse_encoding(mail.text_part.body.to_s)
        end
      else
        if SparkPostRails.configuration.html_content_only || sparkpost_data[:html_content_only]
          @data[:content][:html] = cleanse_encoding(mail.body.to_s)
        else
          @data[:content][:text] = cleanse_encoding(mail.body.to_s)
        end
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
        attachment_data = { name: attachment.inline? ? attachment.cid : attachment.filename,
                            type: attachment.content_type,
                            data: Base64.strict_encode64(attachment.body.decoded) }

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

    def prepare_options_from mail, sparkpost_data
      @data[:options] = Hash.new

      prepare_sandbox_mode_from sparkpost_data
      prepare_open_tracking_from sparkpost_data
      prepare_click_tracking_from sparkpost_data
      prepare_campaign_id_from sparkpost_data
      prepare_return_path_from mail
      prepare_transactional_from sparkpost_data
      prepare_skip_suppression_from sparkpost_data
      prepare_ip_pool_from sparkpost_data
      prepare_inline_css_from sparkpost_data
      prepare_delivery_schedule_from mail
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

    def prepare_open_tracking_from sparkpost_data
      @data[:options][:open_tracking] = SparkPostRails.configuration.track_opens

      if sparkpost_data.has_key?(:track_opens)
        @data[:options][:open_tracking] = sparkpost_data[:track_opens]
      end
    end

    def prepare_click_tracking_from sparkpost_data
      @data[:options][:click_tracking] = SparkPostRails.configuration.track_clicks

      if sparkpost_data.has_key?(:track_clicks)
        @data[:options][:click_tracking] = sparkpost_data[:track_clicks]
      end
    end

    def prepare_campaign_id_from sparkpost_data
      campaign_id = SparkPostRails.configuration.campaign_id

      if sparkpost_data.has_key?(:campaign_id)
        campaign_id = sparkpost_data[:campaign_id]
      end

      if campaign_id
        @data[:campaign_id] = campaign_id
      end
    end

    def prepare_return_path_from mail
      return_path = SparkPostRails.configuration.return_path

      unless mail.return_path.nil?
        return_path = mail.return_path
      end

      if return_path
        @data[:return_path] = return_path
      end
    end

    def prepare_transactional_from sparkpost_data
      @data[:options][:transactional] = SparkPostRails.configuration.transactional

      if sparkpost_data.has_key?(:transactional)
        @data[:options][:transactional] = sparkpost_data[:transactional]
      end
    end


    def prepare_skip_suppression_from sparkpost_data
      if sparkpost_data[:skip_suppression]
        @data[:options][:skip_suppression] = sparkpost_data[:skip_suppression]
      end
    end

    def prepare_description_from sparkpost_data
      if sparkpost_data[:description]
        @data[:description] = sparkpost_data[:description].truncate(1024)
      end
    end

    def prepare_ip_pool_from sparkpost_data
      ip_pool = SparkPostRails.configuration.ip_pool

      if sparkpost_data.has_key?(:ip_pool)
        ip_pool = sparkpost_data[:ip_pool]
      end

      if ip_pool
        @data[:options][:ip_pool] = ip_pool
      end
    end

    def prepare_inline_css_from sparkpost_data
      @data[:options][:inline_css] = SparkPostRails.configuration.inline_css

      if sparkpost_data.has_key?(:inline_css)
        @data[:options][:inline_css] = sparkpost_data[:inline_css]
      end
    end

    def prepare_delivery_schedule_from mail
      # Format YYYY-MM-DDTHH:MM:SS+-HH:MM or "now". Example: '2015-02-11T08:00:00-04:00'. -From SparkPost API Docs
      if mail.date && (mail.date > DateTime.now) && (mail.date < (DateTime.now + 1.year))
        @data[:options][:start_time] = mail.date.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end
    end

    def prepare_additional_mail_headers_from mail
      valid_headers = Hash.new

      invalid_names = ["sparkpost-data",
                       "from",
                       "to",
                       "cc",
                       "bcc",
                       "subject",
                       "reply-to",
                       "return-path",
                       "date",
                       "mime-version",
                       "content-type",
                       "content-transfer-encoding",
                       "text-part"]

      mail.header.fields.each do |field|
        unless invalid_names.include?(field.name.downcase)
          valid_headers[field.name] = field.value
        end
      end

      if valid_headers.count > 0
        unless @data[:content].has_key?(:headers)
          @data[:content][:headers] = Hash.new
        end

        @data[:content][:headers].merge!(valid_headers)
      end
    end

    def prepare_api_headers_from sparkpost_data
      if sparkpost_data.has_key?(:api_key)
        api_key = sparkpost_data[:api_key]
      else
        api_key = SparkPostRails.configuration.api_key
      end

      @headers = {
        "Authorization" => api_key,
        "Content-Type"  => "application/json"
      }

      if sparkpost_data.has_key?(:subaccount)
        subaccount = sparkpost_data[:subaccount]
      else
        subaccount = SparkPostRails.configuration.subaccount
      end

      if subaccount
        @headers["X-MSYS-SUBACCOUNT"] = subaccount.to_s
      end
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
