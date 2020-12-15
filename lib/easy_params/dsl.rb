module EasyParams
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
  end
end
