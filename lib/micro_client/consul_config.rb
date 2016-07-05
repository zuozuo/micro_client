module MicroClient
  class ConsulConfig < Config
    attr_reader :service, :services

    def initialize(service: Diplomat::Service)
      @service = service
      @services = {}
    end

    def get_service(service_name)
      service_name = service_name.to_s.underscore
      service = @services[service_name]
      return service if service
      serv = Diplomat::Service.get('micro_' << service_name)
      if serv.ServiceName.nil?
        nil
      else
        @services[service_name] = Service.new(
          name: service_name, url: serv.ServiceAddress
        )
      end
    end
  end
end
