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
        self.class.new(@title, @default, @optional, @normalize_proc, of: of_type, &@coerce_proc)
      end

      def coerce(value)
        value = @normalize_proc.call(Array(value)) if @normalize_proc
        self.class.new(@title, Array(value).map do |v|
                                 @of_type.coerce(v)
                               end, @normalize_proc, of: @of_type, &@coerce_proc)
      end

      def normalize(&block)
        self.class.new(@title, @default, @optional, block, of: @of_type, &@coerce_proc)
      end

      def self.optional
        self.class.new(@title, @default, true, @normalize_proc, of: @of_type, &@coerce_proc)
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
      def with_type(&block)
        of_type = Class.new(EasyParams::Types::Struct.class).tap { |c| c.class_eval(&block) }.new
        self.class.new(@title, @default, @normalize_proc, of: of_type)
      end
    end
  end
end
