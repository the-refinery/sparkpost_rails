require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Subaccount API Key" do
    it "handles uses supplied subaccount key instead of default API key" do
      SparkPostRails.configure do |c|
        c.api_key = 'NEW_DEFAULT_API_KEY'
      end

      test_email = Mailer.test_email sparkpost_data: {subaccount_api_key: 'SUBACCOUNT_API_KEY'}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("Authorization" => "SUBACCOUNT_API_KEY")
    end

    it "uses default API if no subaccount API key applied" do
      SparkPostRails.configure do |c|
        c.api_key = 'NEW_DEFAULT_API_KEY'
      end
      
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.headers).to include("Authorization" => "NEW_DEFAULT_API_KEY")
    end
  end
end
