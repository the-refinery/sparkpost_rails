require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Message-Specific API Key" do
    it "uses supplied API key instead of default" do
      SparkPostRails.configure do |c|
        c.api_key = 'NEW_DEFAULT_API_KEY'
      end

      test_email = Mailer.test_email sparkpost_data: {api_key: 'SUBACCOUNT_API_KEY'}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("Authorization" => "SUBACCOUNT_API_KEY")
    end

    it "uses default API if no message-specific API key applied" do
      SparkPostRails.configure do |c|
        c.api_key = 'NEW_DEFAULT_API_KEY'
      end
      
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("Authorization" => "NEW_DEFAULT_API_KEY")
    end
  end

  context "Subaccount ID" do
    it "accepts a subaccount ID in the configuration" do
      SparkPostRails.configure do |c|
        c.subaccount = 123
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("X-MSYS-SUBACCOUNT" => "123")
    end

    it "defaults to no subaccount ID in the configuration" do
      expect(SparkPostRails.configuration.subaccount).to eq(nil)
    end

    it "accepts subaccount ID for an individual message" do
      test_email = Mailer.test_email sparkpost_data: {subaccount: 456}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("X-MSYS-SUBACCOUNT" => "456")
    end

    it "uses subaccount ID on message instead of value in configuration" do
      SparkPostRails.configure do |c|
        c.subaccount = 123
      end

      test_email = Mailer.test_email sparkpost_data: {subaccount: 456}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("X-MSYS-SUBACCOUNT" => "456")
    end
    
    it "does not include the subaccount header when none is specified" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers.has_key?("X-MSYS-SUBACCOUNT")).to eq(false)
    end
  end
end
