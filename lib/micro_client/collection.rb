module Micro
  class Collection
    include MicroClient::HttpHelper

    attr_reader :klass, :loaded, :collection, :is_collection

    delegate :each, :map, to: :collection

    def initialize(klass, collection=[])
      @klass = klass
      @loaded = false
      @klasses = [klass]
      @collection = collection
    end

    def loaded?
      !!@loaded
    end

    def loaded!
      @loaded = true
    end

    def unload!
      @loaded = false
    end

    def conditions
      @conditions ||= []
    end

    def collection
      load_data
      @collection
    end

    def reload
      @loaded = false
      load_data
    end
    alias reload! reload

    def to_a
      load_data
      @collection
    end

    def raw_response
      klass.micro_service.send_request(conditions)
    end

    def load_json
      raw_response['results']
    end

    def load_data &block
      if loaded?
        self
      else
        res = klass.micro_service.send_request(conditions)
        loaded!
        handle_response(res, &block)
      end
    end

    def inspect
      load_data
      collection.inspect
    end

    def handle_response(res, &blk)
      results = res['results']
      klass_to_class.reload_structure_by_model_sign(res['model_sign'])

      model = Micro.safe_const_get(res['model'])

      @collection = case results
                    when Array
                      if model && model < Model
                        results.map! { |obj| model.new(obj) }
                      else
                        results
                      end
                    when Hash
                      block_given? ? yield(results) : model.new(results)
                    else
                      results
                    end
    end

    def klass_to_class
      klass.is_a?(Model) ? klass.class : klass
    end

    def supermodule
      klass_to_class.name.deconstantize.constantize
    end

    def http_method_for(type)
      klass_to_class.http_method_for conditions.first.first, type
    end

    private

    def method_missing(meth, *args, &blk)
      conditions << [meth, args]
      self
    end
  end
end
