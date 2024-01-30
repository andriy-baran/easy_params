# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for struct type
    module Struct
      def array?
        false
      end

      def coerce(input)
        return if input.blank?

        self.class.new(input)
      end
    end
  end
end
