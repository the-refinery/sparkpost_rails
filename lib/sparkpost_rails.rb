require "httparty"
require "sparkpost_rails/delivery_method"
require "sparkpost_rails/railtie"

module SparkpostRails
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
      @api_key = ""
      @track_opens = false
      @track_clicks = false
      @campaign_id = "default"
      @return_path = ""
    end
  end
end
