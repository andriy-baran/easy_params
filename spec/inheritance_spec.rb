# frozen_string_literal: true

RSpec.describe 'EasyParams::Base inheritance' do
  describe 'basic inheritance' do
    let(:parent_class) do
      Class.new(EasyParams::Base) do
        integer :id, presence: true
        string :name, presence: true
        integer :age, default: 25
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        string :email, presence: true
      end
    end

    it 'inherits parent schema attributes' do
      expect(child_class.schema.keys).to include(:id, :name, :age)
      expect(child_class.schema.keys).to include(:email)
    end

    it 'inherits parent validations' do
      child_instance = child_class.new(id: nil, name: nil, email: nil)
      child_instance.valid?

      expect(child_instance.errors[:id]).to include("can't be blank")
      expect(child_instance.errors[:name]).to include("can't be blank")
      expect(child_instance.errors[:email]).to include("can't be blank")
    end

    it 'inherits parent defaults' do
      child_instance = child_class.new({})
      expect(child_instance.age).to eq(25)
    end

    it 'can access inherited attributes' do
      child_instance = child_class.new(id: 1, name: 'John', email: 'john@example.com')
      expect(child_instance.id).to eq(1)
      expect(child_instance.name).to eq('John')
      expect(child_instance.email).to eq('john@example.com')
    end

    it 'maintains separate schema instances' do
      expect(child_class.schema).not_to be(parent_class.schema)
      expect(child_class.schema.keys).to include(:id, :name, :age, :email)
      expect(parent_class.schema.keys).to include(:id, :name, :age)
      expect(parent_class.schema.keys).not_to include(:email)
    end
  end

  describe 'multi-level inheritance' do
    let(:grandparent_class) do
      Class.new(EasyParams::Base) do
        integer :id, presence: true
        string :name, presence: true
      end
    end

    let(:parent_class) do
      Class.new(grandparent_class) do
        string :email, presence: true
        integer :age, default: 30
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        string :phone, presence: true
        bool :active, default: true
      end
    end

    it 'inherits from all ancestor levels' do
      expect(child_class.schema.keys).to include(:id, :name, :email, :age, :phone, :active)
    end

    it 'inherits validations from all levels' do
      child_instance = child_class.new({})
      child_instance.valid?

      expect(child_instance.errors[:id]).to include("can't be blank")
      expect(child_instance.errors[:name]).to include("can't be blank")
      expect(child_instance.errors[:email]).to include("can't be blank")
      expect(child_instance.errors[:phone]).to include("can't be blank")
    end

    it 'inherits defaults from all levels' do
      child_instance = child_class.new({})
      expect(child_instance.age).to eq(30)
      expect(child_instance.active).to eq(true)
    end
  end

  describe 'attribute overriding' do
    let(:parent_class) do
      Class.new(EasyParams::Base) do
        string :name, presence: true
        integer :age, default: 25, presence: true
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        # Override age with different default and validation
        integer :age, default: 18, numericality: { greater_than: 17 }
        # Override name with different validation
        string :name, length: { minimum: 2 }
      end
    end

    it 'allows child to override parent attributes' do
      child_instance = child_class.new({})
      expect(child_instance.age).to eq(18) # Uses child's default, not parent's
    end

    it 'uses child validations for overridden attributes' do
      child_instance = child_class.new(age: 16, name: 'A')
      child_instance.valid?

      expect(child_instance.errors[:age]).to include("must be greater than 17")
      expect(child_instance.errors[:name]).to include("is too short (minimum is 2 characters)")
    end
  end

  describe 'nested object inheritance' do
    let(:base_post_class) do
      Class.new(EasyParams::Base) do
        integer :id, presence: true
        string :title, presence: true
        string :content, default: ''
      end
    end

    let(:extended_post_class) do
      Class.new(base_post_class) do
        string :author, presence: true
        date :published_at
      end
    end

    let(:parent_class) do
      base_post = base_post_class
      Class.new(EasyParams::Base) do
        has :post, base_post
        string :category, presence: true
      end
    end

    let(:child_class) do
      extended_post = extended_post_class
      Class.new(parent_class) do
        has :post, extended_post
        string :tags, default: ''
      end
    end

    it 'inherits nested object definitions' do
      child_instance = child_class.new(
        post: { id: 1, title: 'Test', author: 'John' },
        category: 'Tech'
      )

      expect(child_instance.post.id).to eq(1)
      expect(child_instance.post.title).to eq('Test')
      expect(child_instance.post.author).to eq('John')
      expect(child_instance.category).to eq('Tech')
      expect(child_instance.tags).to eq('')
    end

    it 'validates nested objects with inherited definitions' do
      child_instance = child_class.new(
        post: { id: nil, title: '', author: '' },
        category: ''
      )
      child_instance.valid?

      expect(child_instance.errors[:category]).to include("can't be blank")
      expect(child_instance.errors[:"post.id"]).to include("can't be blank")
      expect(child_instance.errors[:"post.title"]).to include("can't be blank")
      expect(child_instance.errors[:"post.author"]).to include("can't be blank")
    end
  end

  describe 'array inheritance' do
    let(:parent_class) do
      Class.new(EasyParams::Base) do
        array :tags, of: :string, default: ['default']
        each :items, default: [{}] do
          string :name, presence: true
        end
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        array :categories, of: :string, default: ['tech']
        each :items do
          string :name, presence: true
          integer :priority, default: 1
        end
      end
    end

    it 'inherits array definitions' do
      child_instance = child_class.new({})
      expect(child_instance.attributes[:tags]).to eq(['default'])
      expect(child_instance.attributes[:categories]).to eq(['tech'])
    end

    it 'inherits each block definitions' do
      child_instance = child_class.new(
        items: [{ name: 'Item 1' }, { name: 'Item 2' }]
      )

      items = child_instance.attributes[:items].to_a
      expect(items.length).to eq(2)
      expect(items.first.name).to eq('Item 1')
      expect(items.first.priority).to eq(1)
      expect(items.last.name).to eq('Item 2')
      expect(items.last.priority).to eq(1)
    end

    it 'validates inherited array elements' do
      child_instance = child_class.new(
        items: [{ name: '' }, { name: 'Valid' }]
      )
      child_instance.valid?

      expect(child_instance.errors[:"items[0].name"]).to include("can't be blank")
      expect(child_instance.errors[:"items[1].name"]).to be_empty
    end
  end

  describe 'schema isolation' do
    let(:parent_class) do
      Class.new(EasyParams::Base) do
        string :shared_attr, presence: true
      end
    end

    let(:child1_class) do
      Class.new(parent_class) do
        string :child1_attr, presence: true
      end
    end

    let(:child2_class) do
      Class.new(parent_class) do
        string :child2_attr, presence: true
      end
    end

    it 'maintains separate schemas for sibling classes' do
      expect(child1_class.schema.keys).to include(:shared_attr, :child1_attr)
      expect(child1_class.schema.keys).not_to include(:child2_attr)

      expect(child2_class.schema.keys).to include(:shared_attr, :child2_attr)
      expect(child2_class.schema.keys).not_to include(:child1_attr)
    end

    it 'does not affect parent schema when child adds attributes' do
      original_parent_schema = parent_class.schema.dup

      child1_class # Trigger schema modification

      expect(parent_class.schema).to eq(original_parent_schema)
    end
  end

  describe 'inherited hook behavior' do
    it 'calls inherited hook when subclassing' do
      expect(EasyParams::Base).to receive(:inherited).and_call_original

      Class.new(EasyParams::Base) do
        string :test_attr
      end
    end

    it 'clones schema in inherited hook' do
      parent = Class.new(EasyParams::Base) do
        string :parent_attr
      end

      child = Class.new(parent) do
        string :child_attr
      end

      expect(child.schema).to include(:parent_attr, :child_attr)
      expect(child.schema).not_to be(parent.schema)
    end
  end
end
