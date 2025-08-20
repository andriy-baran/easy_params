# frozen_string_literal: true

RSpec.describe 'Type definition arguments for has and each' do
  vars do
    section_class do
      Class.new(EasyParams::Types::Struct.class) {
        integer :id
        string :content, default: ''
      }
    end

    post_class do
      Class.new(EasyParams::Types::Struct.class) {
        integer :id
        string :author, default: ''
      }
    end

    params_class do
      sc = section_class
      pc = post_class
      Class.new(EasyParams::Base) do
        each :sections, sc, length: { is: 2, wrong_length: 'is the wrong count (should be 2 sections)' }
        has :post, pc
      end
    end

    attributes do
      {
        sections: [
          { id: '1' }
        ],
        post: { id: '2' }
      }
    end
  end

  it 'coerces and exposes values correctly when class definitions are provided' do
    obj = params_class.new(attributes)
    expect(obj.to_h).to eq(
      sections: [
        { id: 1, content: '' }
      ],
      post: { id: 2, author: '' }
    )
    expect(obj.valid?).to be(false)
    expect(obj.errors.full_messages).to eq(["Sections is the wrong count (should be 2 sections)"])
  end

  context 'when nil is provided' do
    vars do
      attributes { nil }
    end

    it 'builds empty structs/collections based on defaults' do
      obj = params_class.new(attributes)
      expect(obj.to_h).to eq(
        sections: [],
        post: nil
      )
    end
  end
end


