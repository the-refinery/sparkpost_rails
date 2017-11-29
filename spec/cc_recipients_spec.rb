require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "CC Recipients" do
    context "single to recipient and single cc recipient" do
      it "handles email only" do
        test_email = Mailer.test_email cc: "cc@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", header_to: anything}}),
                                                             {address: {email: "cc@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", cc: "Carl Test <cc@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}}),
                                                             {address: {email: "cc@example.com", name: "Carl Test", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end
    end

    context "single to recipient and multiple cc recipients" do
      it "handles email only" do
        test_email = Mailer.test_email cc: "cc1@example.com, cc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", header_to: "to@example.com"}},
                                                             {address: {email: "cc2@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", cc: "Carl Test <cc1@example.com>, Chris Test <cc2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", name: "Carl Test", header_to: "to@example.com"}},
                                                             {address: {email: "cc2@example.com", name: "Chris Test", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end

      it "handles mix of email only and name/email" do
        test_email = Mailer.test_email to: "Joe Test <to@example.com>", cc: "Carl Test <cc1@example.com>, cc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to@example.com", name: "Joe Test", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", name: "Carl Test", header_to: "to@example.com"}},
                                                             {address: {email: "cc2@example.com", header_to: "to@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end
    end

    context "multiple to recipients with single cc recipient" do
      it "handles email only" do
        test_email = Mailer.test_email to: "to1@example.com, to2@example.com", cc: "cc@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}}),
                                                             {address: {email: "cc@example.com", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, Sam Test <to2@example.com>", cc: "Carl Test <cc@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", name: "Sam Test", header_to: anything}}),
                                                             {address: {email: "cc@example.com", name: "Carl Test", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc@example.com"})
      end
    end

    context "multiple to recipients with multiple cc recipients" do
      it "handles email only" do
        test_email = Mailer.test_email to: "to1@example.com, to2@example.com", cc: "cc1@example.com, cc2@example.com"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", header_to: "to1@example.com"}},
                                                             {address: {email: "cc2@example.com", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end

      it "handles name and email" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, Sam Test <to2@example.com>", cc: "Carl Test <cc1@example.com>, Chris Test <cc2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", name: "Sam Test", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", name: "Carl Test", header_to: "to1@example.com"}},
                                                             {address: {email: "cc2@example.com", name: "Chris Test", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end

      it "handles mix of email only and name/email for to recipients" do
        test_email = Mailer.test_email to: "Joe Test <to1@example.com>, to2@example.com", cc: "cc1@example.com, Chris Test <cc2@example.com>"
        @delivery_method.deliver!(test_email)

        expect(@delivery_method.data[:recipients]).to match([a_hash_including({address: {email: "to1@example.com", name: "Joe Test", header_to: anything}}),
                                                             a_hash_including({address: {email: "to2@example.com", header_to: anything}}),
                                                             {address: {email: "cc1@example.com", header_to: "to1@example.com"}},
                                                             {address: {email: "cc2@example.com", name: "Chris Test", header_to: "to1@example.com"}}])
        expect(@delivery_method.data[:content][:headers]).to eq({cc: "cc1@example.com,cc2@example.com"})
      end
    end
  end
end
