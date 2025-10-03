# frozen_string_literal: true

module EasyParams
  module Types
    Array = Collection.new(:array)
    Each = StructsCollection.new(:array_of_structs)
  end
end
