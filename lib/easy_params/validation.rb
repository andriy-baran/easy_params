# frozen_string_literal: true

module EasyParams
  # helpers for recursive validation
  module Validation
    private

    def validate_nested
      attributes.each_value do |value|
        case value
        when EasyParams::Types::StructsCollection
          value.each(&:valid?)
        when EasyParams::Base
          value.valid?
        end
      end
      attributes.each(&aggregate_nested_errors)
    end

    def aggregate_nested_errors
      proc do |attr_name, value, array_index, error_key_prefix|
        case value
        when EasyParams::Types::StructsCollection
          value.each.with_index do |element, i|
            aggregate_nested_errors[attr_name, element, "[#{i}]", error_key_prefix]
          end
        when EasyParams::Base
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
