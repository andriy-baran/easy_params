# frozen_string_literal: true

require 'active_model'
require 'bigdecimal/util'
require 'easy_params/types/generic'
require 'easy_params/types/collection'
require 'easy_params/types/struct'
require 'easy_params/validation'
require 'easy_params/base'
require 'easy_params/types'
require 'easy_params/version'

module EasyParams
  class Error < StandardError; end

  def self.register_type(name, type = nil, &coerce_proc)
    type ||= Generic.new(name, &coerce_proc) if type.nil? && coerce_proc
    Base.types[name] = type
    Base.define_type_method(name)
  end

  register_type :integer, Types::Integer
  register_type :string, Types::String
  register_type :decimal, Types::Decimal
  register_type :float, Types::Float
  register_type :bool, Types::Bool
  register_type :date, Types::Date
  register_type :datetime, Types::DateTime
  register_type :time, Types::Time
end
