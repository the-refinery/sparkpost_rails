require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Inline Content" do
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

    it "supports HTML-only content as a configuration setting" do
      SparkPostRails.configure do |c|
        c.html_content_only = true
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].has_key?(:text)).to eq(false)
      expect(@delivery_method.data[:content][:html]).to eq("Hello, Testing!")
    end

    it "supports HTML-only content as an option on an individual transmission" do
      test_email = Mailer.test_email sparkpost_data: {html_content_only: true}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].has_key?(:text)).to eq(false)
      expect(@delivery_method.data[:content][:html]).to eq("Hello, Testing!")
    end

    it "should not include template details" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].has_key?(:template_id)).to eq(false)
      expect(@delivery_method.data[:content].has_key?(:use_draft_template)).to eq(false)
    end
  end
end

