require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "Recipient Data" do

    it "accepts data matching all recipients" do
      recipients = ['recipient1@email.com', 'recipient2@email.com']
      recipients_data = [
        {substitution_data: {name: "Recipient1"}}, 
        {substitution_data: {name: "Recipient2"}} 
      ]

      test_email = Mailer.test_email to: recipients, sparkpost_data: {recipients: recipients_data}

      @delivery_method.deliver!(test_email)

      actual_recipients = @delivery_method.data[:recipients]
      expect(actual_recipients.length).to eq(recipients.length)
      expect(actual_recipients).to match(recipients.each_with_index.map { |recipient, index| recipients_data[index].merge(address: {email: recipient, header_to: anything}) })
    end

  end
end


