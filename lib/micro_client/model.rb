module Micro
  class Model
    attr_reader :attributes

    delegate :[], to: :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def id
      attributes[:id]
    end

    def collection
      Collection.new(self)
    end

    def delegate_methods
      self.class.model_structure[:instance_methods]
    end

    def <=> (other)
      id <=> other.id
    end

    def inspect
      inspection = @attributes.map do |key, value|
        "#{key}: #{attribute_for_inspect(value)}"
      end.compact.join(", ")

      "#<#{self.class}:#{object_hexid}> #{inspection}"
    end

    def micro_service
      self.class.micro_service
    end

    class << self

      attr_accessor :micro_service

      def model_name
        model_structure[:model_name]
      end

      def collection
        Collection.new(self)
      end

      def delegate_methods
        model_structure[:class_methods]
      end

      def reload_structure
        self.model_structure = micro_service.get_model_structure['results']
      end

      def inherited(subclass)
        if subclass.name
          model_name = subclass.name.demodulize.underscore
          subclass.micro_service = MicroClient.get_service(model_name)
        end
      end

      def model_structure=(structure)
        structure.blank? and return self
        @model_structure = structure.with_indifferent_access
        delegate_methods_to_collection
        define_attributes_methods
      end

      def model_structure
        @model_structure ||= {
          attributes: {},
          class_methods: {},
          instance_methods: {},
          model_name: self.to_s.demodulize.underscore
        }.with_indifferent_access
      end

      def model_sign
        model_structure[:model_sign]
      end

      def attributes
        model_structure[:attributes]
      end

      def micro_instance_methods
        model_structure[:instance_methods].keys
      end

      def micro_class_methods
        model_structure[:class_methods].keys
      end

    #   def handle_es_response(es_collection)
    #     Collection.new(self).tap do |coll|
    #       es_collection.collections.each { |obj| coll << self.new(obj) }
    #     end
    #   end

      private

      def eigenclass
        class << self; self; end
      end

      def delegate_methods_to_collection
        extend Forwardable
        def_delegators :collection, *micro_instance_methods

        extend SingleForwardable
        def_delegators :collection, *micro_class_methods
      end

      def define_attributes_methods
        attributes.each do |col, type|
          define_method col do
            value = @attributes[col]
            value.blank? and return value

            case type.to_sym
            when :datetime
              DateTime.parse value
            when :date
              Date.parse value
            when :decimal
              BigDecimal.new(value)
            else
              value
            end
          end

          define_method "#{col}=" do |value|
            @attributes[col] = value
          end
        end
      end
    end

    private

    def attribute_for_inspect(value)
      if value.is_a?(String) && value.length > 50
        "#{value[0, 50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      elsif value.is_a?(Array) && value.size > 10
        inspected = value.first(10).inspect
        %(#{inspected[0...-1]}, ...])
      else
        value.inspect
      end
    end

    def object_hexid
      "0x00" << (self.object_id << 1).to_s(16)
    end

  end
end
