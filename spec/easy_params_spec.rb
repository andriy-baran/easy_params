# frozen_string_literal: true

RSpec.describe EasyParams do
  vars do
    params_class do
      Class.new(EasyParams::Base) do
        integer :id
        integer :quantity, default: 1
        each :sections do
          integer :id
          string :content, default: ''
          date :updated_at
          has :post do
            integer :id
            param :author, :string, default: ''
            validates :id, presence: { message: "can't be blank1" }
          end
          validates :id, presence: { message: "can't be blank2" }
        end
        has :post do
          param :id, :integer
          param :author, :string, default: ''
          validates :id, presence: { message: "can't be blank3" }
          param :sections, :each do
            param :id, :integer
            param :content, :string, default: ''
            param :updated_at, :date
            has :meta do
              array :copies, of: :string
            end
            validates :id, presence: { message: "can't be blank4" }
          end
        end

        validates :id, :quantity, presence: { message: "can't be blank5" }
        validates :quantity, numericality: { only_integer: true, greater_than: 0 }
      end
    end
    attributes { {} }
    params_obj { params_class.new(attributes) }
  end

  it 'is subclass of ActiveModel::Validations' do
    expect(EasyParams::Base.ancestors).to include(ActiveModel::Validations)
  end
  it 'is subclass of Dry::Struct' do
    expect(EasyParams::Base.superclass).to eq(Dry::Struct)
  end

  describe '.name' do
    it 'returns EasyParams::Base' do
      expect(params_class.name).to eq 'EasyParams::Base'
    end
  end

  context 'public inteface' do
    context 'when validation passes' do
      vars do
        attributes { { id: 2, quantity: 5 } }
      end

      it 'valid? returns true' do
        expect(params_obj).to be_valid
      end
    end

    describe '.to_hash' do
      vars do
        attributes do
          {
            id: 2,
            quantity: 5,
            sections: [
              {
                updated_at: '2018-07-13',
                post: { author: 'Bob' }
              }
            ],
            post: {
              author: 'Bob',
              sections: [
                {
                  updated_at: '2019-07-13',
                  meta: { copies: [] }
                },
                {
                  updated_at: '2019-08-13',
                  meta: { copies: [] }
                }
              ]
            }
          }
        end
        attributes_with_defaults do
          {
            id: 2,
            quantity: 5,
            sections: [
              {
                content: '',
                id: nil,
                updated_at: Date.parse('2018-07-13'),
                post: { id: nil, author: 'Bob' }
              }
            ],
            post: {
              author: 'Bob',
              id: nil,
              sections: [
                {
                  content: '',
                  id: nil,
                  updated_at: Date.parse('2019-07-13'),
                  meta: { copies: [] }
                },
                {
                  content: '',
                  id: nil,
                  updated_at: Date.parse('2019-08-13'),
                  meta: { copies: [] }
                }
              ]
            }
          }
        end
      end

      it 'returns hash with correct values' do
        expect(params_obj.to_hash).to eq attributes_with_defaults
      end
    end

    describe '.validate_nested' do
      vars do
        attributes do
          { id: 2, quantity: 5,
            sections: [{ updated_at: '2018-07-13', post: { author: 'Bob' } }],
            post: { author: 'Bob', sections: [{ updated_at: '2019-07-13' }] } }
        end
      end

      it 'returns hash with correct values' do
        params_obj.valid?
        expect(OpenStruct.new(params_obj.errors.messages)).
          to have_attributes(
                              "sections[0].id": ["can't be blank2"],
                              "sections[0].post.id": ["can't be blank1"],
                              "post.id": ["can't be blank3"],
                              "post.sections[0].id": ["can't be blank4"]
                            )
      end

      context 'rails applicantion nested attributes' do
        vars do
          params_class do
            Class.new(EasyParams::Base) do
              param :title, :string
              param :worker_ids, :array, of: :integer
              has :place_attributes do
                param :city, :string
                param :address, :string

                validates :city, :address, presence: true
              end

              validates :title, presence: true
            end
          end
          attributes { { title: '', worker_ids: [1, 2], place_attributes: { city: '', address: '' } } }
        end

        it 'has proper messages' do
          params_obj.valid?
          expect(OpenStruct.new(params_obj.errors.messages)).to have_attributes(
            "place_attributes.city": ["can't be blank"],
            "place_attributes.address": ["can't be blank"],
            "title": ["can't be blank"]
          )
        end
      end
    end

    context 'when validation does not pass' do
      vars do
        messages { ['Id can\'t be blank5'] }
      end

      it 'invalid? returns true' do
        expect(params_obj).to be_invalid
      end

      it 'has errors messages' do
        params_obj.invalid?
        expect(params_obj.errors.to_a).to eq messages
      end
    end
  end
end
