require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Return Path" do
    it "handles return path set in the configuration" do
      SparkPostRails.configure do |c|
        c.return_path = "BOUNCE-EMAIL@EXAMPLE.COM"
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:return_path]).to eq('BOUNCE-EMAIL@EXAMPLE.COM')
    end

    it "handles return path on an individual message" do
      test_email = Mailer.test_email return_path: "bounce@example.com"

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:return_path]).to eq('bounce@example.com')
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.return_path = "BOUNCE-EMAIL@EXAMPLE.COM"
      end

      test_email = Mailer.test_email return_path: "bounce@example.com"

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:return_path]).to eq('bounce@example.com')
    end

    it "handles a default setting of none" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:return_path)).to eq(false)
    end

  end
end
