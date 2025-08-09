# frozen_string_literal: true

RSpec.describe EasyParams::Types::Array do
  let(:array_of_bool) { EasyParams::Types::Array.of(EasyParams::Types::Bool) }
  let(:array_of_date) { EasyParams::Types::Array.of(EasyParams::Types::Date) }
  let(:array_of_date_time) { EasyParams::Types::Array.of(EasyParams::Types::DateTime) }
  let(:array_of_decimal) { EasyParams::Types::Array.of(EasyParams::Types::Decimal) }
  let(:array_of_float) { EasyParams::Types::Array.of(EasyParams::Types::Float) }
  let(:array_of_integer) { EasyParams::Types::Array.of(EasyParams::Types::Integer) }
  let(:array_of_string) { EasyParams::Types::Array.of(EasyParams::Types::String) }
  let(:array_of_time) { EasyParams::Types::Array.of(EasyParams::Types::Time) }
  let(:array_of_struct) { EasyParams::Types::Array.of(EasyParams::Types::Struct) }
  let(:values) { [nil, '1', 2, 1.1, '1.1', '1.1'.to_d, '2011-11-03', '33-03-2011', '2011-11-03 10:23:45', '2011-11-03 30:23:45', [], {}] }

  describe '#coerce' do
    context 'when bool elements - basic coercion' do
      it 'coerces truthy/falsey values and leaves others as nil' do
        expect(array_of_bool.coerce(['1', '0', 't', 'f', 'yes', nil]).to_a).to eq [true, false, true, false, nil, nil]
      end
    end

    context 'when bool elements' do
      it 'tries to coerce to integer' do
        of_type = array_of_struct.instance_variable_get(:@of_type)
        expect(array_of_struct.coerce(values).to_a).to match_array(
          [nil, instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class), instance_of(of_type.class)]
        )
        expect(array_of_bool.coerce(values).to_a).to eq [nil, true, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
        expect(array_of_date.coerce(values).to_a).to eq [nil, nil, nil, nil, nil, nil, Date.parse('2011-11-03'), nil, Date.parse('2011-11-03'), Date.parse('2011-11-03'), nil, nil]
        expect(array_of_date_time.coerce(values).to_a).to eq [nil, nil, nil, nil, nil, nil, DateTime.parse('2011-11-03'), nil, DateTime.parse('2011-11-03 10:23:45'), nil, nil, nil]
        expect(array_of_decimal.coerce(values).to_a).to eq [nil, 0.1e1, 0.2e1, 0.11e1, 0.11e1, 0.11e1, 0.2011e4, 0.33e2, 0.2011e4, 0.2011e4, nil, nil]
        expect(array_of_float.coerce(values).to_a).to eq [nil, 1.0, 2.0, 1.1, 1.1, 1.1, 2011.0, 33.0, 2011.0, 2011.0, nil, nil]
        expect(array_of_integer.coerce(values).to_a).to eq [nil, 1, 2, 1, 1, 1, 2011, 33, 2011, 2011, nil, nil]
        expect(array_of_string.coerce(values).to_a).to eq [nil, '1', '2', '1.1', '1.1', '0.11e1', '2011-11-03', '33-03-2011', '2011-11-03 10:23:45', '2011-11-03 30:23:45', '[]', '{}']
        expect(array_of_time.coerce(values).to_a).to eq [nil, nil, nil, nil, nil, nil, Time.parse('2011-11-03'), nil, Time.parse('2011-11-03 10:23:45'), nil, nil, nil]
      end
    end
  end

  describe '#default' do
    context 'when default value is an empty array' do
      it 'returns empty array when input is nil' do
        array_with_empty_default = array_of_string.default([])
        result = array_with_empty_default.coerce(nil)
        expect(result.to_a).to eq []
      end

      it 'returns empty array when input is empty array' do
        array_with_empty_default = array_of_integer.default([])
        result = array_with_empty_default.coerce([])
        expect(result.to_a).to eq []
      end

      it 'coerces input values when input is not empty' do
        array_with_empty_default = array_of_bool.default([])
        result = array_with_empty_default.coerce(['1', '0', 'true'])
        expect(result.to_a).to eq [true, false, true]
      end
    end

    context 'when default value is nil' do
      it 'returns nil when input is nil' do
        array_with_nil_default = array_of_float.default(nil)
        result = array_with_nil_default.coerce(nil)
        expect(result.to_a).to eq []
      end

      it 'coerces input values when input is provided' do
        array_with_nil_default = array_of_date.default(nil)
        result = array_with_nil_default.coerce(['2011-11-03', '2012-12-04'])
        expect(result.to_a).to eq [Date.parse('2011-11-03'), Date.parse('2012-12-04')]
      end
    end

    context 'when default value contains valid elements' do
      it 'uses default when input is nil' do
        default_values = ['apple', 'banana', 'cherry']
        array_with_default = array_of_string.default(default_values)
        result = array_with_default.coerce(nil)
        expect(result.to_a).to eq default_values
      end

      it 'coerces input values when input is empty array (empty arrays are not treated as nil)' do
        default_values = [1, 2, 3]
        array_with_default = array_of_integer.default(default_values)
        result = array_with_default.coerce([])
        expect(result.to_a).to eq []
      end

      it 'coerces input values when input is provided' do
        default_values = [true, false]
        array_with_default = array_of_bool.default(default_values)
        result = array_with_default.coerce(['1', '0'])
        expect(result.to_a).to eq [true, false]
      end
    end

    context 'when default value contains invalid elements' do
      it 'handles invalid boolean values gracefully by returning default' do
        default_values = ['invalid_bool', 'true']
        array_with_invalid_default = array_of_bool.default(default_values)

        # The Generic.coerce method catches StandardError and returns @default
        # So invalid values in the default array will cause the entire coercion to fail
        # and return the default value for the individual element
        result = array_with_invalid_default.coerce(nil)
        expect(result.to_a).to eq [nil, true] # First element fails, second succeeds
      end

      it 'handles invalid date values gracefully by returning default' do
        default_values = ['invalid_date', '2011-11-03']
        array_with_invalid_default = array_of_date.default(default_values)

        result = array_with_invalid_default.coerce(nil)
        expect(result.to_a).to eq [nil, Date.parse('2011-11-03')] # First element fails, second succeeds
      end

      it 'handles invalid datetime values gracefully by returning default' do
        default_values = ['invalid_datetime', '2011-11-03 10:23:45']
        array_with_invalid_default = array_of_date_time.default(default_values)

        result = array_with_invalid_default.coerce(nil)
        expect(result.to_a).to eq [nil, DateTime.parse('2011-11-03 10:23:45')] # First element fails, second succeeds
      end
    end

    context 'when default value is a single element' do
      it 'wraps single element in array' do
        array_with_single_default = array_of_string.default('single_item')
        result = array_with_single_default.coerce(nil)
        expect(result.to_a).to eq ['single_item']
      end

      it 'coerces single element to correct type' do
        array_with_single_default = array_of_integer.default('42')
        result = array_with_single_default.coerce(nil)
        expect(result.to_a).to eq [42]
      end
    end

    context 'when default value is not an array' do
      it 'converts hash to array' do
        array_with_hash_default = array_of_string.default({ key: 'value' })
        result = array_with_hash_default.coerce(nil)
        expect(result.to_a).to eq ['[:key, "value"]']
      end

      it 'converts string to array' do
        array_with_string_default = array_of_string.default('not_an_array')
        result = array_with_string_default.coerce(nil)
        expect(result.to_a).to eq ['not_an_array']
      end

      it 'converts number to array' do
        array_with_number_default = array_of_integer.default(123)
        result = array_with_number_default.coerce(nil)
        expect(result.to_a).to eq [123]
      end
    end

    context 'when chaining default with other methods' do
      it 'works with normalize method' do
        array_with_default_and_normalize = array_of_integer
          .default([1, 2, 3])
          .normalize { |arr| arr.reject(&:nil?) }

        result = array_with_default_and_normalize.coerce([nil, 4, nil, 5])
        expect(result.to_a).to eq [4, 5]
      end

      it 'works with of method' do
        array_with_default_and_of = EasyParams::Types::Array
          .default(['1', '2', '3'])
          .of(EasyParams::Types::Integer)

        result = array_with_default_and_of.coerce(nil)
        expect(result.to_a).to eq [1, 2, 3]
      end
    end

    context 'when default value contains mixed types that can be coerced' do
      it 'coerces mixed string numbers to integers' do
        default_values = ['1', 2, '3.0', 4.5]
        array_with_mixed_default = array_of_integer.default(default_values)
        result = array_with_mixed_default.coerce(nil)
        expect(result.to_a).to eq [1, 2, 3, 4]
      end

      it 'coerces mixed values to strings' do
        default_values = [1, 'two', 3.14, true]
        array_with_mixed_default = array_of_string.default(default_values)
        result = array_with_mixed_default.coerce(nil)
        expect(result.to_a).to eq ['1', 'two', '3.14', 'true']
      end

      it 'coerces mixed values to floats' do
        default_values = ['1.5', 2, '3.0', 4]
        array_with_mixed_default = array_of_float.default(default_values)
        result = array_with_mixed_default.coerce(nil)
        expect(result.to_a).to eq [1.5, 2.0, 3.0, 4.0]
      end
    end

    context 'when default value contains nil values' do
      it 'handles nil values in default array' do
        default_values = [nil, 'valid', nil, 'another']
        array_with_nil_default = array_of_string.default(default_values)
        result = array_with_nil_default.coerce(nil)
        expect(result.to_a).to eq [nil, 'valid', nil, 'another']
      end

      it 'coerces nil values when possible' do
        default_values = [nil, '1', nil, '2']
        array_with_nil_default = array_of_integer.default(default_values)
        result = array_with_nil_default.coerce(nil)
        expect(result.to_a).to eq [nil, 1, nil, 2]
      end
    end

    context 'edge cases' do
      it 'handles very large default arrays' do
        large_default = (1..1000).to_a
        array_with_large_default = array_of_integer.default(large_default)
        result = array_with_large_default.coerce(nil)
        expect(result.to_a).to eq large_default
      end

      it 'handles nested arrays in default' do
        nested_default = [[1, 2], [3, 4], [5, 6]]
        array_with_nested_default = array_of_string.default(nested_default)
        result = array_with_nested_default.coerce(nil)
        expect(result.to_a).to eq ['[1, 2]', '[3, 4]', '[5, 6]']
      end

      it 'handles empty string as default' do
        array_with_empty_string_default = array_of_string.default('')
        result = array_with_empty_string_default.coerce(nil)
        expect(result.to_a).to eq ['']
      end

      it 'handles zero as default' do
        array_with_zero_default = array_of_integer.default(0)
        result = array_with_zero_default.coerce(nil)
        expect(result.to_a).to eq [0]
      end

      it 'handles false as default' do
        array_with_false_default = array_of_bool.default(false)
        result = array_with_false_default.coerce(nil)
        expect(result.to_a).to eq [false]
      end
    end
  end
end
