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

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", header_to: anything}})])
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}})])
      end
    end

    context "multiple recipients" do
      it "handles email only" do
        test_email = Mailer.test_email to: "to1@example.com, to2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}})])
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Sam Test <to1@example.com>, Joe Test <to2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({:address=>{:email=>"to1@example.com", :name=>"Sam Test", header_to: anything}}),
                                                             a_hash_including({:address=>{:email=>"to2@example.com", :name=>"Joe Test", header_to: anything}})])
      end

      it "handles mix of email only and name/email" do
        test_email = Mailer.test_email to: "Sam Test <to1@example.com>, to2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match_array([a_hash_including({:address=>{:email=>"to1@example.com", :name=>"Sam Test", header_to: anything}}),
                                                                   a_hash_including({:address=>{:email=>"to2@example.com", header_to: anything}})])
      end

      it "compiles list of email addresses to populate :header_to for each recipient" do
        expected_header_to = "a@a.com,b@b.com"
        test_email = Mailer.test_email to: "a <a@a.com>, b@b.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients].first[:address][:header_to]).to eql(expected_header_to)
        expect(@delivery_method.data[:recipients].second[:address][:header_to]).to eql(expected_header_to)
      end
    end
  end
end
