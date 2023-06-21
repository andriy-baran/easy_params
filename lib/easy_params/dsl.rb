# frozen_string_literal: true

module EasyParams
  # Makes definition more compact
  # Do not use if your attributes have name like
  # integer, decimal, float, bool, string, array, date, datetime, time, struct
  module DSL
    def each(&block)
      array.of(struct_dsl, &block)
    end

    def has(&block)
      struct_dsl(&block)
    end

    def method_missing(method_name, *args, &block)
      public_send(:attribute, method_name, *args, &block)
    end

    def respond_to_missing?(*)
      true
    end
  end
end
