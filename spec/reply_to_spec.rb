require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Reply To" do
    it "handles supplied value" do
      test_email = Mailer.test_email reply_to: "reply_to@example.com"
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:reply_to]).to eq("reply_to@example.com")
    end

    it "handles no value supplied" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].has_key?(:reply_to)).to eq(false)
    end
  end
end

