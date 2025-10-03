# frozen_string_literal: true

RSpec.describe 'Custom type registration' do
  describe 'registering a weight type' do
    before do
      # Register a custom weight type that converts values to kilograms
      EasyParams.register_type :weight do |value|
        case value.to_s.downcase
        when /^(\d+(?:\.\d+)?)\s*kg$/i
          $1.to_f
        when /^(\d+(?:\.\d+)?)\s*lbs?$/i
          $1.to_f * 0.453592  # Convert pounds to kg
        when /^(\d+(?:\.\d+)?)\s*g$/i
          $1.to_f / 1000.0  # Convert grams to kg
        else
          value.to_f
        end
      end
    end

    after do
      # Clean up by removing the custom type
      EasyParams::Base.types.delete(:weight)
    end

    describe 'basic weight type usage' do
      let(:params_class) do
        Class.new(EasyParams::Base) do
          weight :mass, presence: true
          weight :target_weight, default: 70.0
        end
      end

      it 'coerces weight values correctly' do
        obj = params_class.new(mass: '75.5 kg')
        expect(obj.mass).to eq(75.5)
      end

      it 'converts pounds to kilograms' do
        obj = params_class.new(mass: '165 lbs')
        expect(obj.mass).to be_within(0.01).of(74.84)  # 165 lbs ≈ 74.84 kg
      end

      it 'converts grams to kilograms' do
        obj = params_class.new(mass: '5000 g')
        expect(obj.mass).to eq(5.0)
      end

      it 'handles numeric values' do
        obj = params_class.new(mass: 80.5)
        expect(obj.mass).to eq(80.5)
      end

      it 'uses default values' do
        obj = params_class.new({})
        expect(obj.target_weight).to eq(70.0)
      end

      it 'validates presence' do
        obj = params_class.new({})
        expect(obj).to be_invalid
        expect(obj.errors[:mass]).to include("can't be blank")
      end
    end

    describe 'weight type with normalization' do
      let(:params_class) do
        Class.new(EasyParams::Base) do
          weight :weight,
                 default: 70.0,
                 normalize: ->(w) { w.round(1) }
        end
      end

      it 'normalizes weight values' do
        obj = params_class.new(weight: 75.456)
        expect(obj.weight).to eq(75.5)
      end
    end

    describe 'weight type in nested structures' do
      let(:person_class) do
        Class.new(EasyParams::Base) do
          string :name, presence: true
          weight :weight, presence: true
        end
      end

      let(:params_class) do
        person = person_class
        Class.new(EasyParams::Base) do
          has :person, person
          array :weights, of: :weight, default: [65.0, 70.0]
        end
      end

      it 'works in nested has structures' do
        obj = params_class.new(
          person: { name: 'John', weight: '80 kg' }
        )

        expect(obj.person.weight).to eq(80.0)
        expect(obj.person.name).to eq('John')
      end

      it 'works in arrays' do
        obj = params_class.new(weights: ['65 kg', '70 lbs', 75.5])

        weights = obj.weights.to_a
        expect(weights[0]).to eq(65.0)
        expect(weights[1]).to be_within(0.01).of(31.75)  # 70 lbs ≈ 31.75 kg
        expect(weights[2]).to eq(75.5)
      end

      it 'uses array defaults' do
        obj = params_class.new({})
        expect(obj.weights.to_a).to eq([65.0, 70.0])
      end
    end

    describe 'weight type with custom validation' do
      let(:params_class) do
        Class.new(EasyParams::Base) do
          weight :weight,
                 presence: true,
                 numericality: { greater_than: 0, less_than: 500 }
        end
      end

      it 'validates weight range' do
        obj = params_class.new(weight: '600 kg')
        expect(obj).to be_invalid
        expect(obj.errors[:weight]).to include("must be less than 500")
      end

      it 'validates positive weight' do
        obj = params_class.new(weight: '-10 kg')
        expect(obj).to be_invalid
        expect(obj.errors[:weight]).to include("must be greater than 0")
      end

      it 'passes validation for valid weight' do
        obj = params_class.new(weight: '75 kg')
        expect(obj).to be_valid
      end
    end

    describe 'inheritance with custom weight type' do
      let(:parent_class) do
        Class.new(EasyParams::Base) do
          weight :base_weight, default: 60.0
        end
      end

      let(:child_class) do
        Class.new(parent_class) do
          weight :target_weight, default: 70.0
        end
      end

      it 'inherits custom type definitions' do
        obj = child_class.new({})
        expect(obj.base_weight).to eq(60.0)
        expect(obj.target_weight).to eq(70.0)
      end

      it 'can override inherited weight attributes' do
        child_class = Class.new(parent_class) do
          weight :base_weight, default: 65.0
        end

        obj = child_class.new({})
        expect(obj.base_weight).to eq(65.0)
      end
    end

    describe 'error handling for invalid weight formats' do
      let(:params_class) do
        Class.new(EasyParams::Base) do
          weight :weight, default: 70.0
        end
      end

      it 'falls back to default for invalid input' do
        obj = params_class.new(weight: 'invalid_weight')
        expect(obj.weight).to eq(0.0)  # Falls back to default (0.0 from to_f)
      end

      it 'handles nil values' do
        obj = params_class.new(weight: nil)
        expect(obj.weight).to eq(70.0)
      end
    end
  end

  describe 'registering multiple custom types' do
    before do
      # Register weight type
      EasyParams.register_type :weight do |value|
        case value.to_s.downcase
        when /^(\d+(?:\.\d+)?)\s*kg$/i
          $1.to_f
        when /^(\d+(?:\.\d+)?)\s*lbs?$/i
          $1.to_f * 0.453592  # Convert pounds to kg
        when /^(\d+(?:\.\d+)?)\s*g$/i
          $1.to_f / 1000.0  # Convert grams to kg
        else
          value.to_f
        end
      end

      # Register temperature type
      EasyParams.register_type :temperature do |value|
        case value.to_s.downcase
        when /^(\d+(?:\.\d+)?)\s*c$/i
          $1.to_f
        when /^(\d+(?:\.\d+)?)\s*f$/i
          ($1.to_f - 32) * 5.0 / 9.0  # Convert Fahrenheit to Celsius
        else
          value.to_f
        end
      end

      # Register distance type
      EasyParams.register_type :distance do |value|
        case value.to_s.downcase
        when /^(\d+(?:\.\d+)?)\s*km$/i
          $1.to_f
        when /^(\d+(?:\.\d+)?)\s*miles?$/i
          $1.to_f * 1.60934  # Convert miles to km
        else
          value.to_f
        end
      end
    end

    after do
      EasyParams::Base.types.delete(:weight)
      EasyParams::Base.types.delete(:temperature)
      EasyParams::Base.types.delete(:distance)
    end

    it 'allows using multiple custom types together' do
      params_class = Class.new(EasyParams::Base) do
        temperature :room_temp, default: 20.0
        distance :travel_distance, presence: true
        weight :package_weight, default: 1.0
        array :temperatures, of: :temperature, default: [20.0, 25.0]
        array :distances, of: :distance, default: [5.0, 10.0]
      end

      obj = params_class.new(
        room_temp: '72 F',
        travel_distance: '10 miles',
        package_weight: '2.5 kg',
        temperatures: ['68 F', '75 C'],
        distances: ['5 miles', '15 km']
      )

      expect(obj.room_temp).to be_within(0.1).of(22.2)  # 72°F ≈ 22.2°C
      expect(obj.travel_distance).to be_within(0.01).of(16.09)  # 10 miles ≈ 16.09 km
      expect(obj.package_weight).to eq(2.5)

      # Test arrays with custom types
      temps = obj.temperatures.to_a
      expect(temps[0]).to be_within(0.1).of(20.0)  # 68°F ≈ 20°C
      expect(temps[1]).to eq(75.0)  # 75°C stays 75°C

      dists = obj.distances.to_a
      expect(dists[0]).to be_within(0.01).of(8.05)  # 5 miles ≈ 8.05 km
      expect(dists[1]).to eq(15.0)  # 15 km stays 15 km
    end
  end

  describe 'type registration edge cases' do
    it 'raises error when registering type without coercion block' do
      expect {
        EasyParams.register_type(:invalid_type)
      }.to raise_error(ArgumentError)
    end

    it 'allows redefining existing types' do
      # Store original string type
      original_string_type = EasyParams::Base.types[:string]

      # Redefine string type with custom behavior
      EasyParams.register_type :string do |value|
        value.to_s.strip.upcase
      end

      params_class = Class.new(EasyParams::Base) do
        string :name, default: '  john  '
      end

      obj = params_class.new(name: '  john  ')
      expect(obj.name).to eq('JOHN')  # Should be stripped and uppercased

      # Restore original string type
      EasyParams::Base.types[:string] = original_string_type
    end
  end
end
