require "sparkpost_rails/delivery_method"
require "sparkpost_rails/exceptions"
require "sparkpost_rails/railtie"

module SparkPostRails
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key
    attr_accessor :track_opens
    attr_accessor :track_clicks
    attr_accessor :campaign_id
    attr_accessor :return_path

    def initialize
      if ENV.has_key?("SPARKPOST_API_KEY")
        @api_key = ENV["SPARKPOST_API_KEY"]
      else
        @api_key = ""
      end

      @track_opens = false
      @track_clicks = false
      @campaign_id = nil
      @return_path = nil
    end
  end
end
