require 'webmock/rspec'
require 'rails'
require 'action_mailer'
require "sparkpost_rails"

RSpec.configure do |config|

  config.before(:all) do
    ActionMailer::Base.send :include, SparkPostRails::DataOptions
  end

  config.before(:each) do |example|
    if example.metadata[:skip_configure]
      SparkPostRails.configuration = nil # Reset configuration
    else
      SparkPostRails.configure do |c|
        c.api_key = "TESTKEY1234"
      end
    end

    stub_request(:any, "https://api.sparkpost.com/api/v1/transmissions").
      to_return(body: "{\"results\":{\"total_rejected_recipients\":0,\"total_accepted_recipients\":1,\"id\":\"00000000000000000\"}}", status: 200)
  end

end

#A default mailer to generate the mail object
class Mailer < ActionMailer::Base
  def test_email options = {}
    data = {
      from: "from@example.com",
      to: options[:to] || "to@example.com",
      subject: "Test Email",
      text_part: "Hello, Testing!"
    }

    if options.has_key?(:attachments)
      options[:attachments].times do |i|
        attachments["file_#{i}.txt"] = "This is file #{i}"
      end

      options.delete(:attachments)
    end

    if options.has_key?(:images)
      options[:images].times do |i|
        attachments["image_#{i}.png"] = sparkpost_logo_contents
      end

      options.delete(:images)
    end

    if options.has_key?(:inline_attachments)
      options[:inline_attachments].times do |i|
        attachments.inline["image_#{i}.png"] = sparkpost_logo_contents
      end

      options.delete(:inline_attachments)
    end

    if options.has_key?(:headers)
      if options[:headers].class == Hash
        headers options[:headers]
      end

      options.delete(:headers)
    end

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

  def sparkpost_logo_contents
    encoded_contents = "iVBORw0KGgoAAAANSUhEUgAAAfIAAACCCAMAAACKGrqXAAAAY1BMVEX////6\nZCNVVVr6ZCP6ZCNVVVr6ZCNVVVr6ZCP6ZCNVVVpVVVr6ZCNVVVpVVVr6ZCNV\nVVpVVVr6ZCNVVVpVVVpVVVpVVVr6ZCP6ZCNVVVr6ZCP6ZCP6ZCP6ZCNVVVpV\nVVr6ZCO+CfRXAAAAH3RSTlMAgMBAEPBgoDAg4NBwkIDAUBDwQLBgMOCgIFCQ\n0LBwPgQxPgAADDFJREFUeF7s2kGLnEAYhOFqbERhSROHZFzXWer//8rAJo17\n2jklhK73OXsrKItP9Q/hmBQGZ1EWLD6roqB4W5QEdbNnJUFxWOaoTssce1rm\nOGznbTia3VtVDJy27aYYePjDi1KgOLPaidy7whC5V4Uh8l1hiNxVEdDcvSgC\nTnenIsCXVQEw+TIrBOstarPjtKNe5lj9mbLQ6/ak4eEeFjkOf+ai0aGFRY7J\nYZGjhUWOyWGRo4VFjsNhkeMeFjmKsyLHurnLuL7h4dTI2W4Zv8Wg3t1drHHh\nzV3iLxLc3bqmLNS6i6JQ6/asKNS6vSgKtW5raNQ6641a95uGRa2z3qj1rPXG\nbb3TiFA3+9l6WzQQPOwn662ehyJQ6z7+JO6qBNR6/1jefNc4sNtP1luJuMhw\nhLnW2+qIyDnCXOutBUTOEaYrvQY2DQKLvzT1d72rxoD2NPLqD4eGgNlfux7Z\nNTQurd11mts0NLZbJ2nz/9Hs328/vv32fnvV3/N6u/zUaH61d4bLjatIFLZJ\nCL4owsKScEgm8n3/p9zazexi6yC6Wz2pqbo752diLBUfNN3QtP/6m9LdZ85t\nHkv40jB+B4fUd7cHmVB/Tm+2FQJnrPjbnYjPz6apPsyJ17RGx61fn/FcF5Yx\nynw3RP5OX1QanX/A4d0Q18iMSI8dFRd/q8i6CnVza8u7oU1xeGgQ2sjDjda0\nZLppjfjtUV3kPrfrk2DfDRMkjlQx17nKY4VjvIn00Hi22wDnCMhJ+VAaUWPG\nKpAXTaMc+bwe4EnyXL9E7iTHNKi39n3EwW/hMOMvQR7bEO0CxGjZ7cmbVw1m\nDfIik4TI0xpiEj7XLsJJXmb2uXVvJbryCPMfPUDPeuTJkgN6BOS0uoKAMKc6\n5EVBhDxbGHrQ2IW1jDEWuh8mOaHLc0GOv5oWu5+47xbvOPYdLoU5VOTKi6+U\n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\nYII=\n"
    Base64.decode64(encoded_contents)
  end
end
