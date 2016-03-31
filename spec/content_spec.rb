require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Content" do
    it "sets the subject" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:subject]).to eq("Test Email")
    end

    it "handles single part content" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:text]).to eq("Hello, Testing!")
      expect(@delivery_method.data[:content].has_key?(:html)).to eq(false)
    end

    it "handles multi-part content" do
      test_email = Mailer.test_email html_part: "<h1>Hello, Testing!</h1>"
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:text]).to eq("Hello, Testing!")
      expect(@delivery_method.data[:content][:html]).to eq("<h1>Hello, Testing!</h1>")
    end
  end
end

