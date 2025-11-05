# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for struct type
    module Struct
      def array?
        false
      end

      def read_default
        @default
      end

      def normalize_proc
        @normalize_proc
      end

      def default(value)
        self.default = value
        self
      end

      def normalize(&block)
        @normalize_proc = block
        self
      end

      def coerce(value)
        return if value.nil? && @default.nil?

        input = value || @default
        input = @normalize_proc.call(input) if @normalize_proc
        return self.class.new(input) if input.is_a?(Hash)

        self.class.new(input)
      end
    end
  end
end
