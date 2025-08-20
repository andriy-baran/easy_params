# frozen_string_literal: true

module EasyParams
  module Types
    class CoercionError < StandardError; end

    BOOLEAN_MAP =
      { '1' => true, 't' => true, 'true' => true, 'True' => true, 'TRUE' => true, 'T' => true }.merge(
        { '0' => false, 'f' => false, 'false' => false, 'False' => false, 'FALSE' => false, 'F' => false }
      ).freeze

    Struct    = EasyParams::Base.new
    Array     = Collection.new(:array)
    Each      = StructsCollection.new(:array_of_structs)
    Integer   = Generic.new(:integer, &:to_i)
    Float     = Generic.new(:float, &:to_f)
    String    = Generic.new(:string, &:to_s)
    Decimal   = Generic.new(:decimal) { |v| v.to_f.to_d }
    Bool      = Generic.new(:bool) do |v|
      BOOLEAN_MAP.fetch(v.to_s) { raise CoercionError }
    end
    Date = Generic.new(:date) do |v|
      ::Date.parse(v)
    rescue ArgumentError, RangeError
      raise CoercionError, 'cannot be coerced'
    end
    DateTime = Generic.new(:datetime) do |v|
      ::DateTime.parse(v)
    rescue ArgumentError
      raise CoercionError, 'cannot be coerced'
    end
    Time = Generic.new(:time) do |v|
      ::Time.parse(v)
    rescue ArgumentError
      raise CoercionError, 'cannot be coerced'
    end
  end
end
