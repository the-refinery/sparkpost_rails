require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Sandbox Mode" do
    it "handles sandbox mode enabled in the configuration" do
      SparkPostRails.configure do |c|
        c.sandbox = true
      end

      test_email = Mailer.test_email

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:sandbox]).to eq(true)
    end

    it "handles sandbox mode enabled on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {sandbox: true}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:sandbox]).to eq(true)
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.sandbox = true
      end

      test_email = Mailer.test_email sparkpost_data: {sandbox: false}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:sandbox)).to eq(false)
    end

    it "handles a default setting of 'false'" do
      test_email = Mailer.test_email

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:sandbox)).to eq(false)
    end

  end
end

