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
  end
end
