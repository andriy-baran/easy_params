# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for struct type
    module Struct
      def array?
        false
      end

      def default(value)
        self.default = value
        self
      end

      def coerce(input)
        return if input.nil? && @default.nil?
        return self.class.new(@default) if input.nil? && @default.is_a?(Hash)

        self.class.new(input)
      end
    end
  end
end
