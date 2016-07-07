require 'oj'
require 'http'
require 'diplomat'
require 'active_support/all'

require 'micro'
require 'micro_client/exceptions'
require 'micro_client/http_helper'
require 'micro_client/config'
require 'micro_client/collection'
require 'micro_client/model'
require 'micro_client/service'
require 'micro_client/yaml_config'
require 'micro_client/consul_config'

module MicroClient
  extend self

  attr_accessor :config, :environments
  delegate :get_service, to: :config

  def config
    @config ||= ConsulConfig.new
  end

  def configure
    yield(self)
  end

  def get_model(const, micro_model)
    raise 'Please configure MicroClient first.' if config.blank?
    service = get_service(const)
    if service
      service.model
    else
      raise "does not find service #{const} from #{config.class}"
    end
  end
end
