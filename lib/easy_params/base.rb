# frozen_string_literal: true

module EasyParams
  # Implements validations logic and nesting structures
  # rubocop:disable all
  class Base
    include ActiveModel::Model

    def initialize(params = {})
      self.class.schema.each do |attr, type|
        public_send("#{attr}=", type.coerce(params[attr])) if params
      end
    end

    def self.name
      'EasyParams::Base'
    end

    def self.array?
      false
    end

    def self.optional
      @optional ||= true
      self
    end

    def self.coerce(v)
      return if v.blank? && @optional

      new(v)
    end

    def self.attribute(param_name, type)
      attr_accessor param_name
      schema[param_name] = type
    end

    def self.schema
      @schema ||= {}
    end

    def attributes
      self.class.schema.map { |k, type| [k, type.array? ? send(k).to_a : send(k)] }.to_h
    end

    validate do
      validate_nested
    end

    %w[Integer Decimal Float Bool String Date DateTime Time].each do |type_name|
      send(:define_singleton_method,
           type_name.underscore) do |param_name, default: nil, normalize: nil, optional: nil, **validations|
        type = EasyParams::Types.const_get(type_name)
        type = type.default(default) if default
        type = type.optional if optional
        type = type.normalize(&normalize) if normalize
        validates param_name, **validations if validations.any?
        public_send(:attribute, param_name, type)
      end
    end

    def self.each(param_name, normalize: nil, optional: nil, **validations, &block)
      validates param_name, **validations if validations.any?
      type = EasyParams::Types::Each.with_type(&block)
      type = type.optional if optional
      type = type.normalize(&normalize) if normalize
      public_send(:attribute, param_name, type, &block)
    end

    def self.has(param_name, normalize: nil, optional: nil, **validations, &block)
      validates param_name, **validations if validations.any?
      type = Class.new(EasyParams::Types::Struct).tap { |c| c.class_eval(&block) }
      type = type.optional if optional
      type = type.normalize(&normalize) if normalize
      public_send(:attribute, param_name, type, &block)
    end

    def self.array(param_name, of:, normalize: nil, optional: nil, **validations)
      validates param_name, **validations if validations.any?
      of_type = EasyParams::Types.const_get(of.to_s.camelcase)
      type = EasyParams::Types::Array
      type = type.optional if optional
      type = type.normalize(&normalize) if normalize
      public_send(:attribute, param_name, type.of(of_type))
    end

    def to_h
      attributes.each.with_object({}) do |(key, value), result|
        case value
        when *EasyParams::Types::ARRAY_OF_STRUCTS_TYPES_LIST
          result[key] = value.map(&:to_h)
        when *EasyParams::Types::STRUCT_TYPES_LIST
          result[key] = value.to_h
        else
          result[key] = value
        end
      end
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
  # rubocop:enable all
end
