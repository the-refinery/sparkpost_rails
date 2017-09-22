require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "BCC Recipients" do

    context "single bcc recipient, no cc recipients" do
      it "handles email only" do
        test_email = Mailer.test_email bcc: "bcc@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", header_to: anything}}),
                                                             {address: {email: "bcc@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content]).not_to include(:headers)
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, Sam Test <to2@example.com>", bcc: "Brock Test <bcc@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", name: "Sam Test", header_to: anything}}),
                                                             {address: {email: "bcc@example.com", name: "Brock Test", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content]).not_to include(:headers)
      end
    end

    context "multiple bcc recipients, no cc recipientsa" do
      it "handles email only" do
        test_email = Mailer.test_email bcc: "bcc1@example.com, bcc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", header_to: anything}}),
                                                             {address: {email: "bcc1@example.com", header_to: "to@example.com"}},
                                                             {address: {email: "bcc2@example.com", header_to: "to@example.com"}}])

        expect(@delivery_method.data[:content]).not_to include(:headers)
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", bcc: "Brock Test <bcc1@example.com>, Brack Test <bcc2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}}),
                                                             {address: {email: "bcc1@example.com", name: "Brock Test", header_to: "to@example.com"}},
                                                             {address: {email: "bcc2@example.com", name: "Brack Test", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content]).not_to include(:headers)
      end

      it "handles mix of email only and name/email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", bcc: "Brock Test <bcc1@example.com>, bcc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}}),
                                                             {address: {email: "bcc1@example.com", name: "Brock Test", header_to: "to@example.com"}},
                                                             {address: {email: "bcc2@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content]).not_to include(:headers)
      end
    end

    context "bcc and cc recipients" do
      it "handles email only" do
        test_email = Mailer.test_email to: "to1@example.com, to2@example.com", cc: "cc@example.com", bcc: "bcc@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}}),
                                                             {address: {email: "cc@example.com", header_to: "to1@example.com"}},
                                                             {address: {email: "bcc@example.com", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, Sam Test <to2@example.com>", cc: "Carl Test <cc@example.com>", bcc: "Brock Test <bcc@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", name: "Sam Test", header_to: anything}}),
                                                             {address: {email: "cc@example.com", name: "Carl Test", header_to: "to1@example.com"}},
                                                             {address: {email: "bcc@example.com", name: "Brock Test", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end

      it "handles mix of email only and name/email" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, to2@example.com", cc: "cc1@example.com, Chris Test <cc2@example.com>", bcc: "Brock Test <bcc1@example.com>, bcc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", header_to: "to1@example.com"}},
                                                             {address: {email: "cc2@example.com", name: "Chris Test", header_to: "to1@example.com"}},
                                                             {address: {email: "bcc1@example.com", name: "Brock Test", header_to: "to1@example.com"}},
                                                             {address: {email: "bcc2@example.com", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end
    end
  end
end
