# frozen_string_literal: true

module EasyParams
  # Implements validations logic and nesting structures
  class Base
    include ActiveModel::Model
    include EasyParams::Types::Struct
    include EasyParams::Validation

    attr_writer :default

    def initialize(params = {})
      self.class.schema.each do |attr, type|
        public_send("#{attr}=", type.coerce(params.to_h[attr]))
      end
    end

    class << self
      def name
        'EasyParams::Base'
      end

      def attribute(param_name, type)
        attr_accessor param_name

        schema[param_name] = type
      end

      def schema
        @schema ||= {}
      end

      def each(param_name, definition = nil, default: nil, normalize: nil, **validations, &block)
        validates param_name, **validations if validations.any?
        type = EasyParams::Types::Each.with_type(definition, &block)
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      def has(param_name, definition = nil, default: nil, normalize: nil, **validations, &block)
        validates param_name, **validations if validations.any?
        type = (definition || Class.new(EasyParams::Types::Struct.class).tap { |c| c.class_eval(&block) }).new
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      def array(param_name, of:, default: nil, normalize: nil, **validations)
        validates param_name, **validations if validations.any?
        type = EasyParams::Types::Array.of(EasyParams::Types.const_get(of.to_s.camelcase))
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      private

      def customize_type(type, default, &normalize)
        type = type.default(default) if default
        type = type.normalize(&normalize) if normalize
        type
      end
    end

    %w[Integer Decimal Float Bool String Date DateTime Time].each do |type_name|
      send(:define_singleton_method,
           type_name.underscore) do |param_name, default: nil, normalize: nil, **validations|
        validates param_name, **validations if validations.any?
        type = EasyParams::Types.const_get(type_name)
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end
    end

    def attributes
      self.class.schema.to_h { |k, type| [k, type.array? ? send(k).to_a : send(k)] }
    end

    validate do
      validate_nested
    end

    def to_h
      attributes.each.with_object({}) do |(key, value), result|
        result[key] = case value
                      when EasyParams::Types::StructsCollection
                        value.map(&:to_h)
                      when EasyParams::Types::Struct.class
                        value.to_h
                      else
                        value
                      end
      end
    end
  end
end
