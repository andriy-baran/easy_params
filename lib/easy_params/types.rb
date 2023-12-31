# frozen_string_literal: true

module EasyParams
  module Types
    Struct    = EasyParams::Base.meta(omittable: true)
    Has       = EasyParams::Base.meta(omittable: true)
    Integer   = Dry::Types['params.integer'].optional.meta(omittable: true).default(nil)
    Decimal   = Dry::Types['params.decimal'].optional.meta(omittable: true).default(nil)
    Float     = Dry::Types['params.float'].optional.meta(omittable: true).default(nil)
    Bool      = Dry::Types['strict.bool'].optional.meta(omittable: true).default(nil)
    String    = Dry::Types['string'].optional.meta(omittable: true).default(nil)
    Array     = Dry::Types['array'].meta(omittable: true).default([])
    Each      = Dry::Types['array'].of(Struct).meta(omittable: true).default([])
    Date      = Dry::Types['params.date'].optional.meta(omittable: true).default(nil)
    DateTime  = Dry::Types['params.date_time'].optional.meta(omittable: true).default(nil)
    Time      = Dry::Types['params.time'].optional.meta(omittable: true).default(nil)

    STRUCT_TYPES_LIST = [Struct, Has].freeze
    ARRAY_OF_STRUCTS_TYPES_LIST = [Array.of(Struct), Each].freeze
  end
end
