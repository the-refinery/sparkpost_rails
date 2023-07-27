# frozen_string_literal: true

require 'sparkpost_rails/data_options'
require 'sparkpost_rails/delivery_method'
require 'sparkpost_rails/exceptions'
require 'sparkpost_rails/railtie'

module SparkPostRails
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key, :api_endpoint, :sandbox, :track_opens, :track_clicks, :campaign_id, :return_path,
                  :transactional, :ip_pool, :inline_css, :html_content_only, :subaccount

    def initialize
      set_defaults
    end

    def set_defaults
      @api_key = if ENV.key?('SPARKPOST_API_KEY')
                   ENV['SPARKPOST_API_KEY']
                 else
                   ''
                 end

      @api_endpoint = 'https://api.sparkpost.com/api/'

      @sandbox = false

      @track_opens = false
      @track_clicks = false

      @campaign_id = nil
      @return_path = nil

      @transactional = false
      @ip_pool = nil
      @inline_css = false
      @html_content_only = false

      @subaccount = nil
    end
  end
end
