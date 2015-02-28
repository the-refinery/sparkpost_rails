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
          :open_tracking => true,
          :click_tracking => true
        },
        :campaign_id => "",
        :recipients => {},
        :content => {
          :from => {
            :name   => "",
            :email  => ""
          },
          :subject  => "",
          :reply_to => "",
          :text     => "",
          :html     => ""
        }
      }
      puts mail.inspect
      # headers = { "Authorization" => SparkpostRails.configuration.api_key }
      # post('/transmissions', { headers: headers, body: data })
      @response = false
    end
  end
end
