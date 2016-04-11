require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Description" do
    it "handles value from message" do
      test_email = Mailer.test_email sparkpost_data: {description: "Test Email"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:description]).to eq("Test Email")
    end

    it "truncates values longer than 1024 characters" do
      raw_description = "X" * 1050
      truncated_description = ("X" * 1021) + "..."

      test_email = Mailer.test_email sparkpost_data: {description: raw_description}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:description]).to eq(truncated_description)
    end

    it "does not include description element if not supplied" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:description)).to eq(false)
    end

  end
end


