# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for simple types
    class Generic
      attr_reader :normalize_proc

      def initialize(title, default = nil, normalize_proc = nil, &coerce_proc)
        @title = title
        @default = default
        @coerce_proc = coerce_proc
        @normalize_proc = normalize_proc
      end

      def array?
        @title == :array
      end

      def default(value)
        self.class.new(@title, value, @normalize_proc, &@coerce_proc)
      end

      def normalize(&block)
        self.class.new(@title, @default, block, &@coerce_proc)
      end

      def coerce(value)
        value = @normalize_proc.call(value) if @normalize_proc
        return @default if value.nil?

        @coerce_proc.call(value)
      rescue StandardError
        @default
      end
    end
  end
end
