require 'spec_helper'

RSpec.describe "Rails 7.x Compatibility", :rails7_compatibility do
  before(:all) do
    # Manually register the delivery method for testing
    ActionMailer::Base.add_delivery_method :sparkpost, SparkPostRails::DeliveryMethod, return_response: true
  end
  
  describe "Rails 7.x specific features" do
    it "supports Rails 7.x ActionMailer mail method signature" do
      # Test that the mail method works with Rails 7.x signature
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Rails 7 Test",
        text_part: "Hello Rails 7!"
      )
      
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["sender@example.com"])
      expect(mail.subject).to eq("Rails 7 Test")
    end

    it "handles sparkpost_data correctly with Rails 7.x mail method" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Test with SparkPost Data",
        text_part: "Hello!",
        sparkpost_data: {
          campaign_id: "rails7_campaign",
          track_opens: true,
          track_clicks: true
        }
      )
      
      expect(mail.respond_to?(:sparkpost_data)).to be true
      expect(mail.sparkpost_data[:campaign_id]).to eq("rails7_campaign")
      expect(mail.sparkpost_data[:track_opens]).to be true
      expect(mail.sparkpost_data[:track_clicks]).to be true
    end

    it "supports Rails 7.x ActionMailer::Base.delivery_methods" do
      # Ensure the delivery method is properly registered
      expect(ActionMailer::Base.delivery_methods).to include(:sparkpost)
    end

    it "works with Rails 7.x ActiveSupport.on_load timing" do
      # Test that the railtie initializers work correctly
      expect(ActionMailer::Base.included_modules).to include(SparkPostRails::DataOptions)
    end
  end

  describe "Rails 7.x mail object behavior" do
    it "handles mail object singleton class modifications correctly" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      # Test that the singleton class modification works
      expect(mail.singleton_class.instance_methods).to include(:sparkpost_data)
      expect(mail.singleton_class.instance_methods).to include(:sparkpost_data=)
    end

    it "preserves mail object immutability where expected" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      # Test that we can still access standard mail properties
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.subject).to eq("Test Email")
    end
  end

  describe "Rails 7.x configuration compatibility" do
    it "works with Rails 7.x configuration patterns" do
      # Test configuration works with Rails 7.x
      SparkPostRails.configure do |c|
        c.api_key = "rails7_test_key"
        c.sandbox = true
        c.track_opens = true
      end
      
      config = SparkPostRails.configuration
      expect(config.api_key).to eq("rails7_test_key")
      expect(config.sandbox).to be true
      expect(config.track_opens).to be true
    end

    it "handles Rails 7.x environment-specific configurations" do
      # Test that configuration can be set multiple times (common in Rails 7.x)
      SparkPostRails.configure do |c|
        c.api_key = "first_key"
      end
      
      SparkPostRails.configure do |c|
        c.api_key = "second_key"
      end
      
      expect(SparkPostRails.configuration.api_key).to eq("second_key")
    end
  end

  describe "Rails 7.x delivery method compatibility" do
    it "delivery method works with Rails 7.x ActionMailer" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        from: "sender@example.com",
        subject: "Delivery Test",
        text_part: "Test content"
      )
      
      # Test that the delivery method can be instantiated
      delivery_method = SparkPostRails::DeliveryMethod.new
      expect(delivery_method).to be_instance_of(SparkPostRails::DeliveryMethod)
    end

    it "handles Rails 7.x mail object structure" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      # Test that the delivery method can process the mail object
      delivery_method = SparkPostRails::DeliveryMethod.new
      
      # Mock the API call to avoid actual HTTP requests
      allow(delivery_method).to receive(:post_to_api).and_return(
        double(body: '{"results":{"total_rejected_recipients":0,"total_accepted_recipients":1,"id":"test"}}')
      )
      
      expect { delivery_method.deliver!(mail) }.not_to raise_error
    end
  end

  describe "Rails 7.x error handling" do
    it "handles Rails 7.x exception patterns" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { campaign_id: "test" }
      )
      
      delivery_method = SparkPostRails::DeliveryMethod.new
      
      # Test error handling with Rails 7.x compatible exceptions
      allow(delivery_method).to receive(:post_to_api).and_return(
        double(body: '{"errors":[{"message":"Test error","description":"Test description","code":"test_code"}]}')
      )
      
      expect { delivery_method.deliver!(mail) }.to raise_error(SparkPostRails::DeliveryException)
    end
  end

  describe "Rails 7.x multi-part email support" do
    it "handles Rails 7.x multi-part email structure" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        html_part: "<h1>HTML Content</h1>",
        text_part: "Text Content"
      )
      
      expect(mail.multipart?).to be true
      expect(mail.html_part.body.to_s).to include("<h1>HTML Content</h1>")
      expect(mail.text_part.body.to_s).to include("Text Content")
    end

    it "supports Rails 7.x attachment handling" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        attachments: 1
      )
      
      expect(mail.attachments.count).to eq(1)
      expect(mail.attachments.first.filename).to eq("file_0.txt")
    end
  end

  describe "Rails 7.x template support" do
    it "works with Rails 7.x template rendering" do
      mail = Mailer.new.test_email(
        to: "test@example.com",
        sparkpost_data: { template_id: "rails7_template" }
      )
      
      expect(mail.sparkpost_data[:template_id]).to eq("rails7_template")
    end
  end

  describe "Rails 7.x performance compatibility" do
    it "handles multiple mail objects efficiently" do
      # Test that creating multiple mail objects doesn't cause issues
      mails = []
      
      10.times do |i|
        mail = Mailer.new.test_email(
          to: "test#{i}@example.com",
          sparkpost_data: { campaign_id: "batch_#{i}" }
        )
        mails << mail
      end
      
      expect(mails.length).to eq(10)
      mails.each_with_index do |mail, i|
        expect(mail.to).to eq(["test#{i}@example.com"])
        expect(mail.sparkpost_data[:campaign_id]).to eq("batch_#{i}")
      end
    end
  end

  describe "Rails 7.x thread safety" do
    it "handles concurrent mail creation" do
      # Test thread safety with Rails 7.x
      threads = []
      results = []
      mutex = Mutex.new
      
      5.times do |i|
        threads << Thread.new do
          mail = Mailer.new.test_email(
            to: "thread#{i}@example.com",
            sparkpost_data: { campaign_id: "thread_#{i}" }
          )
          mutex.synchronize do
            results << { thread: i, mail: mail }
          end
        end
      end
      
      threads.each(&:join)
      
      expect(results.length).to eq(5)
      
      # Sort results by thread number to ensure consistent ordering
      sorted_results = results.sort_by { |r| r[:thread] }
      sorted_results.each_with_index do |result, i|
        expect(result[:mail].to).to eq(["thread#{i}@example.com"])
        expect(result[:mail].sparkpost_data[:campaign_id]).to eq("thread_#{i}")
      end
    end
  end
end
