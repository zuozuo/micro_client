module MicroClient
  class Config
    attr_accessor :service_name, :service_address

    def get_service
      raise 'This method should be overrided by subclass of MicroClient::Engine'
    end
  end
end
