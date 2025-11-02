# frozen_string_literal: true

class Owner
  def check_name?
    true
  end

  def check_address_city?
    true
  end

  def check_address_zip?
    false
  end

  def check_phone_number?
    true
  end
end

RSpec.describe EasyParams::Composition do
  describe 'composition' do
    let(:params_class) do
      Class.new(EasyParams::Base) do
        integer :id
        string :name, presence: { if: :owner_check_name? }
        has :address do
          string :street
          string :city, presence: { if: :owner_check_address_city? }
          string :state
          string :zip, presence: { if: :owner_check_address_zip? }
        end
        each :phones do
          string :number, presence: { if: :owner_check_phone_number? }
          string :type
        end
      end
    end

    it 'allows composition of attributes' do
      owner = Owner.new
      params = params_class.new(id: 1, address: { street: '123 Main St', city: nil, state: 'CA' }, phones: [{ number: nil, type: 'home' }, { number: '098-765-4321', type: 'work' }])
      params.owner = owner
      expect(params).to be_invalid
      expect(params.errors[:name]).to include("can't be blank")
      expect(params.address.errors[:city]).to include("can't be blank")
      expect(params.phones[0].errors[:number]).to include("can't be blank")
      expect(params.owner).to eq owner
      expect(params.address.owner).to eq params
      expect(params.phones.owner).to eq params
      expect(params.phones[0].owner).to eq(params.phones)
      expect(params.phones[1].owner).to eq(params.phones)
    end
  end
end