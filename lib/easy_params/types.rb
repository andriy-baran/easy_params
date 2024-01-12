# frozen_string_literal: true

module EasyParams
  module Types
    Struct    = EasyParams::Base
    Integer   = Dry::Types['params.integer'].optional.default(nil)
    Decimal   = Dry::Types['params.decimal'].optional.default(nil)
    Float     = Dry::Types['params.float'].optional.default(nil)
    Bool      = Dry::Types['params.bool'].optional.default(nil)
    String    = Dry::Types['coercible.string'].optional.default(nil)
    Array     = Dry::Types['array'].default([].freeze)
    Date      = Dry::Types['params.date'].optional.default(nil)
    DateTime  = Dry::Types['params.date_time'].optional.default(nil)
    Time      = Dry::Types['params.time'].optional.default(nil)

    STRUCT_TYPES_LIST = [Struct].freeze
    ARRAY_OF_STRUCTS_TYPES_LIST = [Array.of(Struct)].freeze
  end
end
