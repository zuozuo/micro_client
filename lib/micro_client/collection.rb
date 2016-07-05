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

    def load_json
      klass.micro_service.send_request(conditions)['results']
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

      if res['model_sign'] != klass_to_class.model_sign
        klass_to_class.reload_structure
      end

      _class = Micro.const_get(res['model'])

      @collection = case results
                    when Array
                      if _class < Model
                        results.map! { |obj| _class.new(obj) }
                      else
                        results
                      end
                    when Hash
                      block_given? ? yield(results) : _class.new(results)
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
