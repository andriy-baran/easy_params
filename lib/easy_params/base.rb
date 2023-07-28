# frozen_string_literal: true

module EasyParams
  # Implements validations logic and nesting structures
  class Base < Dry::Struct
    include ActiveModel::Validations

    transform_keys(&:to_sym)

    def self.name
      'EasyParams::Base'
    end

    %w[Integer Decimal Float Bool String Array Date DateTime Time Struct StructDSL].each do |type|
      send(:define_singleton_method, type.underscore) { EasyParams::Types.const_get(type) }
    end

    validate do
      validate_nested
    end

    private

    def validate_nested
      attributes.each do |_, value|
        case value
        when self.class.array.of(self.class.struct)
          value.each(&:valid?)
        when self.class.struct
          value.valid?
        end
      end
      attributes.each(&aggregate_nested_errors)
    end

    def aggregate_nested_errors
      proc do |attr_name, value, array_index, error_key_prefix|
        case value
        when self.class.array.of(self.class.struct)
          value.each.with_index do |element, i|
            aggregate_nested_errors[attr_name, element, "[#{i}]", error_key_prefix]
          end
        when self.class.struct
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
