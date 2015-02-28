module SparkpostRails
  class DeliveryMethod
    include HTTParty
    base_uri "https://api.sparkpost.com/api"

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
      puts mail
      #post('/v1/transmissions', data)
    end
  end
end
