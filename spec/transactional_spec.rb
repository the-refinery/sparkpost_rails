require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Transactional" do
    it "handles transactional flag set in the configuration" do
      SparkPostRails.configure do |c|
        c.transactional = true
      end

      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:transactional]).to eq(true)
    end

    it "handles transactional set on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {transactional: true}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:transactional]).to eq(true)
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.transactional = true
      end

      test_email = Mailer.test_email sparkpost_data: {transactional: false}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:transactional]).to eq(false)
    end

    it "handles unset value" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:transactional]).to eq(false)
    end

  end
end
