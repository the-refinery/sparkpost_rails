require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Delivery Schedule" do
    it "handles supplied future DateTime value less than a year from now" do
      start_time = (DateTime.now + 4.hours)
      formatted_start_time = start_time.strftime("%Y-%m-%dT%H:%M:%S%:z")

      test_email = Mailer.test_email date: start_time
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options][:start_time]).to eq(formatted_start_time)
    end

    it "does not include start_time if date is in the past" do
      start_time = (DateTime.now - 4.hours)
      
      test_email = Mailer.test_email date: start_time
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:start_time)).to eq(false)
    end

    it "does not include start_time if date is more than 1 year from now" do
      start_time = (DateTime.now + 4.years)
      
      test_email = Mailer.test_email date: start_time
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:start_time)).to eq(false)
    end

    it "does not include start_time if not set" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:options].has_key?(:start_time)).to eq(false)
    end
  end
end

