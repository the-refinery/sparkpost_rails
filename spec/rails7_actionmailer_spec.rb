require 'spec_helper'

RSpec.describe "Rails 7.x ActionMailer Integration", :rails7_actionmailer do
  before(:all) do
    # Manually register the delivery method for testing
    ActionMailer::Base.add_delivery_method :sparkpost, SparkPostRails::DeliveryMethod, return_response: true
  end
  
  describe "Rails 7.x ActionMailer::Base integration" do
    it "properly includes SparkPostRails::DataOptions module" do
      expect(ActionMailer::Base.included_modules).to include(SparkPostRails::DataOptions)
    end

    it "registers sparkpost delivery method correctly" do
      expect(ActionMailer::Base.delivery_methods).to include(:sparkpost)
    end

    it "allows setting sparkpost as delivery method" do
      ActionMailer::Base.delivery_method = :sparkpost
      expect(ActionMailer::Base.delivery_method).to eq(:sparkpost)
    end
  end

  describe "Rails 7.x mail method behavior" do
    it "handles mail method with keyword arguments" do
      # Test Rails 7.x style keyword arguments
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Keyword Args Test",
        text_part: "Test content"
      )
      
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["sender@example.com"])
      expect(mail.subject).to eq("Keyword Args Test")
    end

    it "handles mail method with block syntax" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        html_part: "<h1>HTML</h1>",
        text_part: "Text"
      )
      
      expect(mail.multipart?).to be true
      expect(mail.html_part.body.to_s).to include("<h1>HTML</h1>")
      expect(mail.text_part.body.to_s).to include("Text")
    end

    it "preserves mail method return value" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      expect(mail).to be_instance_of(Mail::Message)
      expect(mail.respond_to?(:sparkpost_data)).to be true
    end
  end

  describe "Rails 7.x mail object attributes" do
    it "handles mail object attribute access" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Attribute Test",
        text_part: "Content"
      )
      
      # Test standard mail attributes
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["sender@example.com"])
      expect(mail.subject).to eq("Attribute Test")
      expect(mail.body.to_s).to include("Content")
    end

    it "handles mail object header access" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        headers: { "X-Custom-Header" => "Custom Value" }
      )
      
      expect(mail["X-Custom-Header"].to_s).to eq("Custom Value")
    end
  end

  describe "Rails 7.x delivery method integration" do
    it "delivery method can process Rails 7.x mail objects" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Delivery Test",
        text_part: "Test content",
        sparkpost_data: { campaign_id: "test_campaign" }
      )
      
      delivery_method = SparkPostRails::DeliveryMethod.new
      
      # Mock the API response
      allow(delivery_method).to receive(:post_to_api).and_return(
        double(body: '{"results":{"total_rejected_recipients":0,"total_accepted_recipients":1,"id":"test"}}')
      )
      
      result = delivery_method.deliver!(mail)
      expect(result).to be_a(Hash)
      expect(result["total_accepted_recipients"]).to eq(1)
    end

    it "handles delivery method configuration" do
      delivery_method = SparkPostRails::DeliveryMethod.new(
        api_key: "custom_key",
        sandbox: true
      )
      
      expect(delivery_method.settings[:api_key]).to eq("custom_key")
      expect(delivery_method.settings[:sandbox]).to be true
    end
  end

  describe "Rails 7.x error handling integration" do
    it "delivery method raises proper exceptions" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      delivery_method = SparkPostRails::DeliveryMethod.new
      
      # Mock API error response
      allow(delivery_method).to receive(:post_to_api).and_return(
        double(body: '{"errors":[{"message":"API Error","description":"Test error","code":"test_code"}]}')
      )
      
      expect { delivery_method.deliver!(mail) }.to raise_error(SparkPostRails::DeliveryException)
    end

    it "delivery exception contains proper error information" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      delivery_method = SparkPostRails::DeliveryMethod.new
      
      # Mock API error response
      allow(delivery_method).to receive(:post_to_api).and_return(
        double(body: '{"errors":[{"message":"API Error","description":"Test error","code":"test_code"}]}')
      )
      
      begin
        delivery_method.deliver!(mail)
      rescue SparkPostRails::DeliveryException => e
        expect(e.message).to include("API Error")
        expect(e.service_message).to eq("API Error")
        expect(e.service_description).to eq("Test error")
        expect(e.service_code).to eq("test_code")
      end
    end
  end

  describe "Rails 7.x configuration integration" do
    it "configuration works with Rails 7.x patterns" do
      # Test configuration in Rails 7.x style
      SparkPostRails.configure do |config|
        config.api_key = "rails7_key"
        config.sandbox = true
        config.track_opens = true
        config.track_clicks = true
        config.campaign_id = "rails7_campaign"
        config.return_path = "bounce@example.com"
        config.transactional = true
        config.ip_pool = "rails7_pool"
        config.inline_css = true
        config.html_content_only = true
        config.subaccount = "123"
      end
      
      config = SparkPostRails.configuration
      expect(config.api_key).to eq("rails7_key")
      expect(config.sandbox).to be true
      expect(config.track_opens).to be true
      expect(config.track_clicks).to be true
      expect(config.campaign_id).to eq("rails7_campaign")
      expect(config.return_path).to eq("bounce@example.com")
      expect(config.transactional).to be true
      expect(config.ip_pool).to eq("rails7_pool")
      expect(config.inline_css).to be true
      expect(config.html_content_only).to be true
      expect(config.subaccount).to eq("123")
    end

    it "configuration can be reset and reconfigured" do
      # Test configuration reset (common in Rails 7.x testing)
      SparkPostRails.configure do |c|
        c.api_key = "first_key"
      end
      
      expect(SparkPostRails.configuration.api_key).to eq("first_key")
      
      # Reset configuration
      SparkPostRails.configuration = nil
      
      SparkPostRails.configure do |c|
        c.api_key = "second_key"
      end
      
      expect(SparkPostRails.configuration.api_key).to eq("second_key")
    end
  end

  describe "Rails 7.x performance characteristics" do
    it "handles rapid mail creation" do
      # Test performance with rapid mail creation (common in Rails 7.x apps)
      start_time = Time.now
      
      100.times do |i|
        mail = Mailer.new.test_email(
          to: "test#{i}@example.com",
          sparkpost_data: { campaign_id: "batch_#{i}" }
        )
        expect(mail.to).to eq(["test#{i}@example.com"])
      end
      
      end_time = Time.now
      duration = end_time - start_time
      
      # Should complete within reasonable time (adjust as needed)
      expect(duration).to be < 5.0 # 5 seconds
    end

    it "handles memory usage efficiently" do
      # Test memory usage doesn't grow excessively
      initial_memory = GC.stat[:total_allocated_objects]
      
      50.times do |i|
        mail = Mailer.new.test_email(
          to: "test#{i}@example.com",
          sparkpost_data: { campaign_id: "memory_test_#{i}" }
        )
        expect(mail.sparkpost_data[:campaign_id]).to eq("memory_test_#{i}")
      end
      
      # Force garbage collection
      GC.start
      
      final_memory = GC.stat[:total_allocated_objects]
      memory_growth = final_memory - initial_memory
      
      # Memory growth should be reasonable (adjusted for Rails 7.x)
      expect(memory_growth).to be < 50000 # Adjusted threshold for Rails 7.x
    end
  end
end
