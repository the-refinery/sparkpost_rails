require 'spec_helper'

describe SparkPostRails::DeliveryMethod do

  before(:each) do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context "API Response Handling" do
    it "returns result data on success" do
      test_email = Mailer.test_email
      response = @delivery_method.deliver!(test_email)

      expect(response).to eq({"total_rejected_recipients"=>0, "total_accepted_recipients"=>1, "id"=>"00000000000000000"})
    end

    it "raises exception on error" do
      stub_request(:any, "https://api.sparkpost.com/api/v1/transmissions").
        to_return(body: "{\"errors\":[{\"message\":\"required field is missing\",\"description\":\"recipients or list_id required\",\"code\":\"1400\"}]}", status: 403)

      test_email = Mailer.test_email

      expect {@delivery_method.deliver!(test_email)}.to raise_exception(SparkPostRails::DeliveryException)
    end
  end
end
