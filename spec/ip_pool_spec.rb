require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "IP Pool" do
    it "handles ip_pool set in the configuration" do
      SparkPostRails.configure do |c|
        c.ip_pool = "default_ip"
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:ip_pool]).to eq("default_ip")
    end

    it "handles ip_pool set on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {ip_pool: "message_ip"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:ip_pool]).to eq("message_ip")
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.ip_pool = "default_ip"
      end

      test_email = Mailer.test_email sparkpost_data: {ip_pool: "message_ip"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:ip_pool]).to eq("message_ip")
    end

    it "handles a default setting of none" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:ip_pool)).to eq(false)
    end

  end
end
