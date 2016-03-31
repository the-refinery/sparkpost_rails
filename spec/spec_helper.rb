require 'webmock/rspec'
require 'rails'
require 'action_mailer'
require "sparkpost_rails"

RSpec.configure do |config|

  config.before(:all) do
    SparkPostRails.configure do |c|
      c.api_key = "TESTKEY1234"
    end
  end

  config.before(:each) do
    stub_request(:any, "https://api.sparkpost.com/api/v1/transmissions").
      to_return(body: "{\"response\":{\"total_rejected_recipients\":0,\"total_accepted_recipients\":1,\"id\":\"00000000000000000\"}}", status: 200)
  end

end

#A default mailer to generate the mail object
class Mailer < ActionMailer::Base
  def test_email options = {}
    data = {
      from: "from@example.com",
      to: "to@example.com",
      subject: "Test Email",
      text_part: "Hello, Testing!"
    }

    data.merge! options

    if data.has_key?(:html_part)

      mail(data) do |format|
        format.text {render text: data[:text_part]}
        format.html {render text: data[:html_part]}
      end

    else

      mail(data) do |format|
        format.text {render text: data[:text_part]}
      end

    end


  end
end
