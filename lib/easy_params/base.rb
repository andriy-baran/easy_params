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
      def inherited(subclass)
        super
        subclass.clone_schema(self)
        subclass.types = types.dup
      end

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

      def types
        @types ||= {}
      end

      attr_writer :types

      def each(param_name, definition = nil, default: nil, normalize: nil, **validations, &block)
        validates param_name, **validations if validations.any?
        if definition && !(definition < EasyParams::Base)
          raise ArgumentError, "definition for attribute #{param_name.inspect} must be a subclass of EasyParams::Base"
        end

        type = EasyParams::Types::Each.with_type(definition, &block)
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      def has(param_name, definition = nil, default: nil, normalize: nil, **validations, &block)
        validates param_name, **validations if validations.any?
        if definition && !(definition < EasyParams::Base)
          raise ArgumentError, "definition for attribute #{param_name.inspect} must be a subclass of EasyParams::Base"
        end

        type = (definition || Class.new(EasyParams::Base).tap { |c| c.class_eval(&block) }).new
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      def array(param_name, of:, default: nil, normalize: nil, **validations)
        validates param_name, **validations if validations.any?
        type = EasyParams::Types::Array.of(types[of])
        type = customize_type(type, default, &normalize)
        attribute(param_name, type)
      end

      def clone_schema(parent)
        @schema = parent.schema.dup
      end

      def define_type_method(type_name)
        define_singleton_method(type_name) do |param_name, default: nil, normalize: nil, **validations|
          validates param_name, **validations if validations.any?
          type = customize_type(types[type_name], default, &normalize)
          attribute(param_name, type)
        end
      end

      private

      def customize_type(type, default, &normalize)
        type = type.default(default) if default
        type = type.normalize(&normalize) if normalize
        type
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
                      when EasyParams::Base
                        value.to_h
                      else
                        value
                      end
      end
    end
  end
end
