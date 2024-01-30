# frozen_string_literal: true

RSpec.describe EasyParams::Types::Bool do
  let(:type) { EasyParams::Types::Bool }

  describe '#array?' do
    it 'returns false' do
      expect(type.array?).to eq false
    end
  end

  describe '#default' do
    it 'creates new type with default value' do
      type_with_default = type.default(false)
      expect(type_with_default).to_not eq type
    end
  end

  describe '#normalize' do
    it 'creates new type with preprocessing proc' do
      type_with_normalizer = type.normalize { |v| !!v }
      expect(type_with_normalizer).to_not eq type
    end
  end

  describe '#coerce' do
    context 'when initial type setup' do
      it 'tries to coerce to integer' do
        EasyParams::Types::BOOLEAN_MAP.each do |value, output|
          expect(type.coerce(value)).to eq output
        end
        expect(type.coerce(nil)).to eq nil
        expect(type.coerce('1')).to eq true
        expect(type.coerce(1)).to eq true
        expect(type.coerce(1.1)).to eq nil
        expect(type.coerce('1.1')).to eq nil
        expect(type.coerce('1.1'.to_d)).to eq nil
        expect(type.coerce('1')).to eq true
        expect(type.coerce('2011-11-03')).to eq nil
        expect(type.coerce({})).to eq nil
        expect(type.coerce([])).to eq nil
      end
    end

    context 'when default set' do
      it 'tries to coerce to integer' do
        type_with_default = type.default(10)
        expect(type_with_default.coerce(nil)).to eq 10
        expect(type_with_default.coerce('')).to eq 10
        expect(type_with_default.coerce(1)).to eq true
        expect(type_with_default.coerce(1.1)).to eq 10
        expect(type_with_default.coerce('1.1')).to eq 10
        expect(type_with_default.coerce('1.1'.to_d)).to eq 10
        expect(type_with_default.coerce('1')).to eq true
        expect(type_with_default.coerce('2011-11-03')).to eq 10
        expect(type_with_default.coerce({})).to eq 10
        expect(type_with_default.coerce([])).to eq 10
      end
    end

    context 'when normalizer set' do
      it 'is called before coercion' do
        value = double(to_norm: '1')
        type_with_normalizer = type.normalize { |v| v.to_norm }
        expect(type_with_normalizer.coerce(value)).to eq true
      end
    end

    context 'when default set and normalizer set' do
      it 'is normalized and coerced' do
        value = double(to_norm: '')
        value2 = double(to_norm: nil)
        value3 = double(to_norm: 1.2)
        type_with_normalizer = type.normalize { |v| v.to_norm }
        configured_type = type_with_normalizer.default(10)
        expect(configured_type.coerce(value)).to eq 10
        expect(configured_type.coerce(value2)).to eq 10
        expect(configured_type.coerce(value3)).to eq 10
      end
    end
  end
end
