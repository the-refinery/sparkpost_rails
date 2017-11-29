require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Headers" do
    it "passes appropriate headers through to the API" do
      test_email = Mailer.test_email headers: {"Priority" => "urgent", "Sensitivity" => "private"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:headers]).to eq({"Priority" => "urgent", "Sensitivity" => "private"})
    end

    it "is compatible with CC functionality" do
      test_email = Mailer.test_email cc: "Carl Test <cc@example.com>", headers: {"Priority" => "urgent", "Sensitivity" => "private"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com", "Priority" => "urgent", "Sensitivity" => "private"})
    end

    it "does not pass inappropriate headers through to the API" do
      test_email = Mailer.test_email headers: {content_type: "POSTSCRIPT", "Priority" => "urgent", "Sensitivity" => "private"}
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:headers]).to eq({"Priority" => "urgent", "Sensitivity" => "private"})
    end

  end
end

