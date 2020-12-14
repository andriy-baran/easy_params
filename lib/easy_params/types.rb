module EasyParams
  module Types
    include Dry::Types.module
    Struct    = EasyParams::Base.meta(omittable: true)
    StructDSL = ::Class.new(EasyParams::Base).extend(EasyParams::DSL).meta(omittable: true)
    Integer   = EasyParams::Types::Params::Integer.optional.meta(omittable: true).default(nil)
    Decimal   = EasyParams::Types::Params::Decimal.optional.meta(omittable: true).default(nil)
    Float     = EasyParams::Types::Params::Float.optional.meta(omittable: true).default(nil)
    Bool      = EasyParams::Types::Strict::Bool.optional.meta(omittable: true).default(nil)
    String    = EasyParams::Types::String.optional.meta(omittable: true).default(nil)
    Array     = EasyParams::Types::Array.of(Struct).meta(omittable: true).default([])
    Date      = EasyParams::Types::Params::Date.optional.meta(omittable: true).default(nil)
    DateTime  = EasyParams::Types::Params::DateTime.optional.meta(omittable: true).default(nil)
    Time      = EasyParams::Types::Params::Time.optional.meta(omittable: true).default(nil)
  end
end
