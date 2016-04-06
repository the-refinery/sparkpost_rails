require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Options" do

    it "does not contain unset campaign_id" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:campaign_id)).to eq(false)
    end

    it "contains supplied campaign_id" do
      SparkPostRails.configure do |c|
        c.campaign_id = "ABCD1234"
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:campaign_id]).to eq("ABCD1234")
    end

    it "does not contain unset return_path" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:return_path)).to eq(false)
    end

    it "contains supplied return_path" do
      SparkPostRails.configure do |c|
        c.return_path = "BOUNCE-EMAIL@EXAMPLE.COM"
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:return_path]).to eq('BOUNCE-EMAIL@EXAMPLE.COM')
    end
  end
end
