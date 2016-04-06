require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Recipients List" do

    it "handles a list_id" do
      test_email = Mailer.test_email sparkpost_data: {recipient_list_id: "List1"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:recipients]).to eq({list_id: "List1"})
    end

    it "ignores any CC addresses" do
      test_email = Mailer.test_email cc: "cc@example.com", sparkpost_data: {recipient_list_id: "List1"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:recipients]).to eq({list_id: "List1"})
      expect(@delivery_method.data[:content].has_key?(:headers)).to eq(false)
    end

    it "ignores any BCC addresses" do
      test_email = Mailer.test_email bcc: "cc@example.com", sparkpost_data: {recipient_list_id: "List1"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:recipients]).to eq({list_id: "List1"})
    end
  end

end
