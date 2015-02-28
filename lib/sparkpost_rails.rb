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

    def initialize
      @api_key = ''
    end
  end
end
