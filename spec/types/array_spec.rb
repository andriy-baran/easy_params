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
    context 'when bool elements' do
      it 'fails' do
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
end
