require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "No CC Recipients" do

  end

  context "CC Recipients" do

    context "single recipient and single cc recipient" do
      it "handles email only" do
        test_email = Mailer.test_email cc: "cc@example.com"
        @delivery_method.deliver!(test_email)

        puts @delivery_method.data

        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com"}}, {address: {email: "cc@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: ["cc@example.com"]})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", cc: "Carl Copy <cc@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com", name: "Joe Test"}}, {address: {email: "cc@example.com", name: "Carl Copy", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: ["cc@example.com"]})
      end
    end

    context "single recipient and multiple cc recipients" do
      it "handles email only" do
        test_email = Mailer.test_email cc: "cc1@example.com, cc2@example.com"
        @delivery_method.deliver!(test_email)
        
        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com"}}, {address: {email: "cc1@example.com", header_to: "to@example.com"}}, {address: {email: "cc2@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: ["cc1@example.com", "cc2@example.com"]})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", cc: "Carl Copy <cc1@example.com>, Chris Copy <cc2@example.com>"
        @delivery_method.deliver!(test_email)
        
        expect(@delivery_method.data[:recipients]).to eq([{address: {email: "to@example.com", name: "Joe Test"}}, {address: {email: "cc1@example.com", name: "Carl Copy", header_to: "to@example.com"}}, {address: {email: "cc2@example.com", name: "Chris Copy", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: ["cc1@example.com", "cc2@example.com"]})
      end

    #   it "handles mix of email only and name/email" do
    #     test_email = Mailer.test_email to: "Sam Test <to1@example.com>, to2@example.com"
    #     @delivery_method.deliver!(test_email)

    #     expect(@delivery_method.data[:recipients]).to eq([{:address=>{:email=>"to1@example.com", :name=>"Sam Test"}}, {:address=>{:email=>"to2@example.com"}}])
    #   end
    end
  end
end
