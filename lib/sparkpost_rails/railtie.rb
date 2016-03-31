module SparkPostRails
  class Railtie < Rails::Railtie
    initializer "sparkpost_rails.add_delivery_method" do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method :sparkpost, SparkPostRails::DeliveryMethod, return_response: true
      end
    end
  end
end
