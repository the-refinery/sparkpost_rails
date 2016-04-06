require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    SparkPostRails.configuration.set_defaults
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Open Tracking" do
    it "handles open tracking enabled in the configuration" do
      SparkPostRails.configure do |c|
        c.track_opens = true
      end

      test_email = Mailer.test_email

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:open_tracking]).to eq(true)
    end

    it "handles open tracking enabled on an individual message" do
      test_email = Mailer.test_email sparkpost_data: {track_opens: true}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:open_tracking]).to eq(true)
    end

    it "handles the value on an individual message overriding configuration" do
      SparkPostRails.configure do |c|
        c.track_opens = true
      end

      test_email = Mailer.test_email sparkpost_data: {track_opens: false}

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:open_tracking]).to eq(false)
    end

    it "handles a default setting of 'false'" do
      test_email = Mailer.test_email

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:open_tracking]).to eq(false)
    end

  end
end


