module EasyParams
  module Types
    Struct    = EasyParams::Base.meta(omittable: true)
    StructDSL = ::Class.new(EasyParams::Base).extend(EasyParams::DSL).meta(omittable: true)
    Integer   = Dry::Types['params.integer'].optional.meta(omittable: true).default(nil)
    Decimal   = Dry::Types['params.decimal'].optional.meta(omittable: true).default(nil)
    Float     = Dry::Types['params.float'].optional.meta(omittable: true).default(nil)
    Bool      = Dry::Types['strict.bool'].optional.meta(omittable: true).default(nil)
    String    = Dry::Types['string'].optional.meta(omittable: true).default(nil)
    Array     = Dry::Types['array'].of(Struct).meta(omittable: true).default([])
    Date      = Dry::Types['params.date'].optional.meta(omittable: true).default(nil)
    DateTime  = Dry::Types['params.date_time'].optional.meta(omittable: true).default(nil)
    Time      = Dry::Types['params.time'].optional.meta(omittable: true).default(nil)
  end
end
