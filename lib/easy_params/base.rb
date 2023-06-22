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

    def validate_nested
      attributes.each(&run_nested_validations)
    end

    def run_nested_validations
      proc do |attr_name, value, array_index, error_key_prefix|
        case value
        when Array
          value.each.with_index do |element, i|
            run_nested_validations[attr_name, element, i, error_key_prefix]
          end
        when self.class.struct
          handle_struct_validation(value, error_key_prefix, attr_name, array_index)
        end
      end
    end

    def handle_struct_validation(value, error_key_prefix, attr_name, array_index)
      if value.invalid?
        error_key_components = [error_key_prefix, attr_name, array_index]
        attr_error_key_prefix = error_key_components.compact.join('/')
        add_errors_on_top_level(value, attr_error_key_prefix)
      end
      value.attributes.each do |nested_attr_name, nested_value|
        run_nested_validations[nested_attr_name, nested_value, nil, attr_error_key_prefix]
      end
    end

    if defined? ActiveModel::Error
      def add_errors_on_top_level(value, attr_error_key_prefix)
        value.errors.each do |error|
          next unless error.options[:message]

          errors.add("#{attr_error_key_prefix}/#{error.attribute}", error.options[:message])
        end
      end
    else
      def add_errors_on_top_level(value, attr_error_key_prefix)
        value.errors.each { |key, message| errors.add("#{attr_error_key_prefix}/#{key}", message) }
      end
    end
  end
end
