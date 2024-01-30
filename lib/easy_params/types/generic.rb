# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for simple types
    class Generic
      def array?
        @title == :array
      end

      def initialize(title, default = nil, normalize_proc = nil, &coerce_proc)
        @title = title
        @default = default
        @coerce_proc = coerce_proc
        @normalize_proc = normalize_proc
      end

      def default(value)
        self.class.new(@title, value, @normalize_proc, &@coerce_proc)
      end

      def optional
        self.class.new(@title, @default, @normalize_proc, &@coerce_proc)
      end

      def optional?
        @optional
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
