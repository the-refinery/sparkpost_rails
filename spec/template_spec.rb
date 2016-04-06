require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Templates" do

    it "accepts the template id to use" do
      test_email = Mailer.test_email sparkpost_data: {template_id: "test_template"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:template_id]).to eq("test_template")
    end

    it "accepts substitution data" do
      sub_data = {item_1: "test data 1", item_2: "test data 2"}

      test_email = Mailer.test_email sparkpost_data: {template_id: "test_template", substitution_data: sub_data}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:substitution_data]).to eq(sub_data)
    end

    it "does not include substitution data element if none is passed" do
      test_email = Mailer.test_email sparkpost_data: {template_id: "test_template"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.has_key?(:substitution_data)).to eq(false)
    end

    it "does not include inline content elements" do
      test_email = Mailer.test_email sparkpost_data: {template_id: "test_template"}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].has_key?(:from)).to eq(false)
      expect(@delivery_method.data[:content].has_key?(:reply_to)).to eq(false)

      expect(@delivery_method.data[:content].has_key?(:subject)).to eq(false)

      expect(@delivery_method.data[:content].has_key?(:html)).to eq(false)
      expect(@delivery_method.data[:content].has_key?(:text)).to eq(false)
      expect(@delivery_method.data[:content].has_key?(:attachments)).to eq(false)
      expect(@delivery_method.data[:content].has_key?(:inline_images)).to eq(false)
    end

  end
end
