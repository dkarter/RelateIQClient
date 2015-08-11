require 'rest_client'

require 'relateiq/service_factory'
require 'relateiq/utils/field_value_encoder'
require 'relateiq/contact'
require 'relateiq/account'
require 'relateiq/list'
require 'relateiq/list_item'

module RelateIq
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    RestClient.log = self.configuration.logger
  end

  class Configuration
    attr_accessor :base_url, :username, :password, :logger

    def initialize
      @base_url = 'https://api.relateiq.com/v2'
      @username = ''
      @password = ''
    end
  end
end
