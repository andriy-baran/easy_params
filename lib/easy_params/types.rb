# frozen_string_literal: true

module EasyParams
  module Types
    class Generic
      attr_reader :title

      def array?
        @title == :array
      end

      def initialize(title, default = nil, &coerce_proc)
        @title = title
        @default = default
        @coerce_proc = coerce_proc
        @optional = nil
      end

      def default(value)
        self.class.new(@title, value, &@coerce_proc)
      end

      def self.optional
        @optional ||= true
        self
      end

      def coerce(value)
        return @default if value.nil? && @default
        return value unless value.is_a?(::String)

        @coerce_proc.call(value) || @default
      end
    end

    class Collection < Generic
      include Enumerable

      def initialize(default = [], of: nil)
        super(:array, default)
        @of_type = of
      end

      def of(of_type)
        self.class.new(of: of_type)
      end

      def coerce(value)
        self.class.new(Array(value).map { |v| @of_type.coerce(v) })
      end

      def each(&block)
        @default.each(&block)
      end
    end

    class StructsCollection < Collection
      def initialize(default = [], of: nil)
        super
        @title = :array_of_structs
      end

      def with_type(&block)
        of_type = Class.new(EasyParams::Types::Struct).tap { |c| c.class_eval(&block) }
        self.class.new(of: of_type)
      end
    end

    Struct    = EasyParams::Base
    Integer   = Generic.new(:integer) { |v| v.to_i }
    Decimal   = Generic.new(:decimal) { |v| v.to_f.to_d }
    Float     = Generic.new(:float) { |v| v.to_f }
    Bool      = Generic.new(:bool) { |v| !!v }
    String    = Generic.new(:string) { |v| v.to_s }
    Date      = Generic.new(:date) { |v| ::Date.parse(v) }
    DateTime  = Generic.new(:datetime) { |v| ::DateTime.parse(v) }
    Time      = Generic.new(:time) { |v| ::Time.parse(v) }
    Array     = Collection.new
    Each      = StructsCollection.new

    STRUCT_TYPES_LIST = [Struct].freeze
    ARRAY_OF_STRUCTS_TYPES_LIST = [StructsCollection].freeze
  end
end
