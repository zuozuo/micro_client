require 'yaml'

module MicroClient
  class YamlConfig < Config
    attr_reader :services

    def initialize(file: )
      @services = YAML.load_file(file)
    end

    def get_service(service_name)
      url = @services[service_name.to_s]
      if url.blank?
        nil
      else
        Service.new(name: service_name, url: url)
      end
    end
  end
end
