# frozen_string_literal: true

module EasyParams
  # Implements validations logic and nesting structures
  class Base < Dry::Struct
    include ActiveModel::Validations

    transform_keys(&:to_sym)

    def self.name
      'EasyParams::Base'
    end

    validate do
      validate_nested
    end

    # %w[Integer Decimal Float Bool String Date DateTime Time Array Struct StructDSL].each do |type|
    %w[Integer Decimal Float Bool String Date DateTime Time].each do |type_name|
      send(:define_singleton_method, type_name.underscore) do |param_name, default: nil, normalize: nil, **validations|
        type = EasyParams::Types.const_get(type_name)
        type = type.default(default) if default
        type = type.constructor { |value| value == Dry::Types::Undefined ? value : normalize.call(value) } if normalize
        validates param_name, **validations if validations.any?
        public_send(:attribute, param_name, type)
      end
    end

    def self.each(param_name, normalize: nil, **validations, &block)
      validates param_name, **validations if validations.any?
      type = EasyParams::Types::Each
      type = type.constructor { |value| value == Dry::Types::Undefined ? value : normalize.call(value) } if normalize
      public_send(:attribute, param_name, type, &block)
    end

    def self.has(param_name, normalize: nil, **validations, &block)
      validates param_name, **validations if validations.any?
      type = EasyParams::Types::Struct
      type = type.constructor { |value| value == Dry::Types::Undefined ? value : normalize.call(value) } if normalize
      public_send(:attribute, param_name, type, &block)
    end

    def self.array(param_name, of:, normalize: nil, **validations, &block)
      validates param_name, **validations if validations.any?
      of_type = EasyParams::Types.const_get(of.to_s.camelcase)
      type = EasyParams::Types::Array
      type = type.constructor { |value| value == Dry::Types::Undefined ? value : normalize.call(value) } if normalize
      public_send(:attribute, param_name, type.of(of_type), &block)
    end

    def self.param(method_name, type_name, of: nil, default: nil, **validations, &block)
      type = EasyParams::Types.const_get(type_name.to_s.camelcase)
      type = type.default(default) if default
      type = type.of(EasyParams::Types.const_get(of.to_s.camelcase)) if of && type_name != :each
      validates method_name, **validations if validations.any?
      public_send(:attribute, method_name, type, &block)
    end

    private

    def validate_nested
      attributes.each do |_, value|
        case value
        when *EasyParams::Types::ARRAY_OF_STRUCTS_TYPES_LIST
          value.each(&:valid?)
        when *EasyParams::Types::STRUCT_TYPES_LIST
          value.valid?
        end
      end
      attributes.each(&aggregate_nested_errors)
    end

    def aggregate_nested_errors
      proc do |attr_name, value, array_index, error_key_prefix|
        case value
        when *EasyParams::Types::ARRAY_OF_STRUCTS_TYPES_LIST
          value.each.with_index do |element, i|
            aggregate_nested_errors[attr_name, element, "[#{i}]", error_key_prefix]
          end
        when *EasyParams::Types::STRUCT_TYPES_LIST
          handle_nested_errors(value, error_key_prefix, attr_name, array_index)
        end
      end
    end

    def handle_nested_errors(value, error_key_prefix, attr_name, array_index)
      return if value.errors.blank?

      error_key_components = [error_key_prefix, attr_name, array_index]
      attr_error_key_prefix = error_key_components.compact.join('.').gsub(/\.\[(\d+)\]/, '[\1]')
      add_errors_on_top_level(value, attr_error_key_prefix)
    end

    if defined? ActiveModel::Error
      def add_errors_on_top_level(value, attr_error_key_prefix)
        value.errors.each { |error| errors.add("#{attr_error_key_prefix}.#{error.attribute}", error.message) }
      end
    else
      def add_errors_on_top_level(value, attr_error_key_prefix)
        value.errors.each { |key, message| errors.add("#{attr_error_key_prefix}.#{key}", message) }
      end
    end
  end
end
