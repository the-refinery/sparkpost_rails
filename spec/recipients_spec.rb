require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Recipients" do

    context "single recipient" do
      it "handles email only" do
        test_email = Mailer.test_email
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com"}}])
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com", name: "Joe Test"}}])
      end
    end

    context "multiple recipients" do
      it "handles email only" do
        test_email = Mailer.test_email to: "to1@example.com, to2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to1@example.com"}}, {address: {email: "to2@example.com"}}])
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Sam Test <to1@example.com>, Joe Test <to2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{:address=>{:email=>"to1@example.com", :name=>"Sam Test"}}, {:address=>{:email=>"to2@example.com", :name=>"Joe Test"}}])
      end

      it "handles mix of email only and name/email" do
        test_email = Mailer.test_email to: "Sam Test <to1@example.com>, to2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{:address=>{:email=>"to1@example.com", :name=>"Sam Test"}}, {:address=>{:email=>"to2@example.com"}}])
      end
    end
  end
end
