require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Campaign ID" do
    it "handles campaign id in the configuration" do
      SparkPostRails.configure do |c|
        c.campaign_id = "ABCD1234"
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:campaign_id]).to eq("ABCD1234")
    end

    it "handles campaign id on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {campaign_id: "My Campaign"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:campaign_id]).to eq("My Campaign")
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.campaign_id = "ABCD1234"
      end

      test_email = Mailer.test_email sparkpost_data: {campaign_id: "My Campaign"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:campaign_id]).to eq("My Campaign")
    end

    it "handles the value on an individual message of nil overriding configuration" do
      SparkPostRails.configure do |c|
        c.campaign_id = "ABCD1234"
      end

      test_email = Mailer.test_email sparkpost_data: {campaign_id: nil}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:campaign_id)).to eq(false)
    end

    it "handles a default setting of none" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:campaign_id)).to eq(false)
    end

  end
end


