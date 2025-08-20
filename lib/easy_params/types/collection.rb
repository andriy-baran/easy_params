# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for array type
    class Collection < Generic
      include Enumerable

      def initialize(*attrs, of: nil)
        super(*attrs)
        @of_type = of
      end

      def of(of_type)
        self.class.new(@title, @default, @normalize_proc, of: of_type, &@coerce_proc)
      end

      def coerce(value)
        input = value || @default
        input = @normalize_proc.call(Array(input)) if @normalize_proc
        coerced = Array(input).map { |v| @of_type.coerce(v) }
        self.class.new(@title, coerced, @normalize_proc, of: @of_type, &@coerce_proc)
      end

      def normalize(&block)
        self.class.new(@title, @default, block, of: @of_type, &@coerce_proc)
      end

      def default(value)
        self.class.new(@title, value, @normalize_proc, of: @of_type, &@coerce_proc)
      end

      def each(&block)
        @default.each(&block)
      end
    end

    # base interface for array of structs type
    class StructsCollection < Collection
      def with_type(definition = nil, &block)
        of_type = (definition || Class.new(EasyParams::Base).tap { |c| c.class_eval(&block) }).new
        self.class.new(@title, @default, @normalize_proc, of: of_type)
      end
    end
  end
end
