require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Inline css" do
    it "handles inline_css set in the configuration" do
      SparkPostRails.configure do |c|
        c.inline_css = true
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:inline_css]).to eq(true)
    end

    it "handles inline_css set on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {inline_css: true}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:inline_css]).to eq(true)
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.inline_css = false
      end

      test_email = Mailer.test_email sparkpost_data: {inline_css: true}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:inline_css]).to eq(true)
    end

    it "handles a default setting of inline_css" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:inline_css]).to eq(false)
    end
  end
end
