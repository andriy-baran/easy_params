# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for simple types
    class Generic
      def array?
        @title == :array
      end

      def initialize(title, default = nil, optional = nil, normalize_proc = nil, &coerce_proc)
        @title = title
        @default = default
        @coerce_proc = coerce_proc
        @normalize_proc = normalize_proc
        @optional = optional
      end

      def default(value)
        self.class.new(@title, value, @normalize_proc, &@coerce_proc)
      end

      def optional
        self.class.new(@title, @default, true, @normalize_proc, &@coerce_proc)
      end

      def coerce(value)
        value = @normalize_proc.call(value) if @normalize_proc
        return @default if value.nil? && @default
        return value unless value.is_a?(::String)

        @coerce_proc.call(value) || @default
      end

      def normalize(&block)
        self.class.new(@title, @default, @optional, block, &@coerce_proc)
      end
    end
  end
end
