module SparkpostRails
  class DeliveryMethod
    include HTTParty
    base_uri "https://api.sparkpost.com/api/v1"

    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      data = {
        :options => {
          :open_tracking => SparkpostRails.configuration.track_opens,
          :click_tracking => SparkpostRails.configuration.track_clicks
        },
        :campaign_id => "",
        :recipients => [
          {
            :address => {
              # :name   => "",
              :email  => mail.to.first
            }
          }
        ],
        :content => {
          :from => {
            # :name   => "",
            :email  => mail.from.first
          },
          :subject  => mail.subject,
          :reply_to => mail.reply_to.first,
          :text     => mail.text_part,
          :html     => mail.html_part
        }
      }
      headers = { "Authorization" => SparkpostRails.configuration.api_key }
      post('/transmissions', { headers: headers, body: data })
      @response = false
    end
  end
end
