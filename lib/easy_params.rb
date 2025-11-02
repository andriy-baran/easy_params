# frozen_string_literal: true

require 'active_model'
require 'bigdecimal/util'
require 'easy_params/composition'
require 'easy_params/types/generic'
require 'easy_params/types/collection'
require 'easy_params/types/struct'
require 'easy_params/validation'
require 'easy_params/base'
require 'easy_params/types'
require 'easy_params/version'

# EasyParams provides a simple way to define parameter classes with type coercion and validation
module EasyParams
  class Error < StandardError; end
  class CoercionError < StandardError; end

  def self.types
    @types ||= {}
  end

  def self.register_type(name, type = nil, &coerce_proc)
    if type.nil? && coerce_proc
      type = Types::Generic.new(name, &coerce_proc)
    elsif type.nil? && !coerce_proc
      raise ArgumentError, 'Either a type instance or a coercion block must be provided'
    end
    types[name] = type
    Base.define_type_method(name)
  end

  BOOLEAN_MAP =
    { '1' => true, 't' => true, 'true' => true, 'True' => true, 'TRUE' => true, 'T' => true }.merge(
      { '0' => false, 'f' => false, 'false' => false, 'False' => false, 'FALSE' => false, 'F' => false }
    ).freeze

  register_type :integer, &:to_i
  register_type :float, &:to_f
  register_type :string, &:to_s
  register_type(:decimal) { |v| v.to_f.to_d }
  register_type(:bool) do |v|
    v.is_a?(TrueClass) || v.is_a?(FalseClass) ? v : BOOLEAN_MAP.fetch(v.to_s) { raise CoercionError }
  end
  register_type(:date) do |v|
    v.is_a?(Date) ? v : Date.parse(v)
  rescue ArgumentError, RangeError
    raise CoercionError, 'cannot be coerced'
  end
  register_type(:datetime) do |v|
    v.is_a?(DateTime) ? v : DateTime.parse(v)
  rescue ArgumentError
    raise CoercionError, 'cannot be coerced'
  end
  register_type(:time) do |v|
    v.is_a?(Time) ? v : Time.parse(v)
  rescue ArgumentError
    raise CoercionError, 'cannot be coerced'
  end
end
