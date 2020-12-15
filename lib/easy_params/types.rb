module EasyParams
  module Types
    include Dry::Types.module
    Struct    = EasyParams::Base.meta(omittable: true)
    StructDSL = ::Class.new(EasyParams::Base).extend(EasyParams::DSL).meta(omittable: true)
    Integer   = Params::Integer.optional.meta(omittable: true).default(nil)
    Decimal   = Params::Decimal.optional.meta(omittable: true).default(nil)
    Float     = Params::Float.optional.meta(omittable: true).default(nil)
    Bool      = Strict::Bool.optional.meta(omittable: true).default(nil)
    String    = String.optional.meta(omittable: true).default(nil)
    Array     = Array.of(Struct).meta(omittable: true).default([])
    Date      = Params::Date.optional.meta(omittable: true).default(nil)
    DateTime  = Params::DateTime.optional.meta(omittable: true).default(nil)
    Time      = Params::Time.optional.meta(omittable: true).default(nil)
  end
end
