# frozen_string_literal: true

RSpec.describe EasyParams::Types::Date do
  let(:type) { EasyParams::Types::Date }

  describe '#array?' do
    it 'returns false' do
      expect(type.array?).to eq false
    end
  end

  describe '#optional' do
    it 'is not optional by initially' do
      expect(type.optional?).to eq nil
    end

    it 'creates new type marked as optional' do
      optional_type = type.optional
      expect(optional_type.optional?).to eq true
    end
  end

  describe '#default' do
    it 'creates new type with default value' do
      type_with_default = type.default(1)
      expect(type_with_default).to_not eq type
    end
  end

  describe '#normalize' do
    it 'creates new type with preprocessing proc' do
      type_with_normalizer = type.normalize { |v| v.to_s.sub(/\.\d+$/, '') }
      expect(type_with_normalizer).to_not eq type
    end
  end

  describe '#coerce' do
    context 'when initial type setup' do
      it 'tries to coerce to integer' do
        expect(type.coerce(nil)).to eq nil
        expect(type.coerce('')).to eq nil
        expect(type.coerce(1)).to eq nil
        expect(type.coerce(1.1)).to eq nil
        expect(type.coerce('1.1')).to eq nil
        expect(type.coerce('1.1'.to_d)).to eq nil
        expect(type.coerce('1')).to eq nil
        expect(type.coerce('2011-11-03')).to eq Date.parse('2011-11-03')
        expect(type.coerce('33-03-2011')).to eq nil
        expect(type.coerce('2011-11-03 10:23:45')).to eq Date.parse('2011-11-03')
        expect(type.coerce('2011-11-03 30:23:45')).to eq Date.parse('2011-11-03')
        expect(type.coerce({})).to eq nil
        expect(type.coerce([])).to eq nil
      end
    end

    context 'when default set' do
      it 'tries to coerce to integer' do
        type_with_default = type.default(10)
        expect(type_with_default.coerce(nil)).to eq 10
        expect(type_with_default.coerce('')).to eq 10
        expect(type_with_default.coerce(1)).to eq 10
        expect(type_with_default.coerce(1.1)).to eq 10
        expect(type_with_default.coerce('1.1')).to eq 10
        expect(type_with_default.coerce('1.1'.to_d)).to eq 10
        expect(type_with_default.coerce('1')).to eq 10
        expect(type_with_default.coerce('2011-11-03')).to eq Date.parse('2011-11-03')
        expect(type_with_default.coerce('33-03-2011')).to eq 10
        expect(type_with_default.coerce('2011-11-03 10:23:45')).to eq Date.parse('2011-11-03')
        expect(type_with_default.coerce('2011-11-03 30:23:45')).to eq Date.parse('2011-11-03')
        expect(type_with_default.coerce({})).to eq 10
        expect(type_with_default.coerce([])).to eq 10
      end
    end

    context 'when normalizer set' do
      it 'is called before coercion' do
        value = double(to_norm: '2011-11-03')
        type_with_normalizer = type.normalize { |v| v.to_norm }
        expect(type_with_normalizer.coerce(value)).to eq Date.parse('2011-11-03')
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
