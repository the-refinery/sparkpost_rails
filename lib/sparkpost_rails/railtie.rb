module SparkpostRails
  class Railtie < Rails::Railtie
    initializer "sparkpost_rails.add_delivery_method" do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method :sparkpost, SparkpostRails::DeliveryMethod
      end
    end
  end
end
