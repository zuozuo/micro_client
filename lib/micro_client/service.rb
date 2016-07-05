module MicroClient
  class Service
    include HttpHelper

    attr_accessor :name, :url, :model

    def initialize(name:, url:)
      @name, @url = name, url
      setup_model
    end

    def setup_model
      res = get_model_structure

      micro_service = self
      @model = Class.new(Micro::Model).tap do |model|
        Micro.const_set name.camelcase, model
        model.model_structure = res['results']
        model.model_structure[:model_sign] = res['model_sign']
        model.micro_service = micro_service
      end
    end

    def resource_url
      if model.is_a?(Micro::Model)
        "#{url}/#{model.id}"
      else
        url
      end
    end

    def get_model_structure
      get "#{url}/micro_model_structure"
    end

    def send_request(conditions)
      meth, args = conditions.first
      verb = model.delegate_methods[meth]

      if conditions.length == 1
        public_send verb, "#{resource_url}/#{meth}", args: args.to_json
      else
        public_send verb, resource_url, { methods: conditions.to_json }
      end
    end
  end
end
