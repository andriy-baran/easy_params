# frozen_string_literal: true

module EasyParams
  module Types
    # base interface for struct type
    module Struct
      def array?
        false
      end

      def optional
        @optional ||= true
        self
      end

      def coerce(input)
        return if input.blank? && @optional

        self.class.new(input)
      end
    end
  end
end
