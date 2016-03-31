require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "From" do
    it "handles email only" do
      test_email = Mailer.test_email
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:from]).to eq({email: "from@example.com"})
    end

    it "handles name and email" do
      test_email = Mailer.test_email from: "Joe Test <from@example.com>"
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:from]).to eq({:email=>"from@example.com", :name=>"Joe Test"})
    end
  end
end
