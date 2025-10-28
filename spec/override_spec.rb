RSpec.describe EasyParams do
  describe 'override validations' do
    let(:params_class) do
      Class.new(EasyParams::Base) do
        integer :id, presence: true
        has :post, default: {} do
          integer :id
          string :title
          string :content
          date :published_at, default: Date.today
        end
        each :comments, default: [{}, {}] do
          integer :post_id
          string :author
          string :text
        end
      end
    end

    it 'allows overriding validations' do
      params_class.post_schema do
        validates :title, :content, presence: true, if: :published?

        def published?
          published_at.present?
        end
      end
      expect(params_class.new(id: 1, post: { title: nil, content: nil })).to be_invalid
    end

    it 'allows overriding defaults' do
      params_class.comments_schema do
        string :author, default: 'Anonymous'
        date :created_at, default: Date.today
        validates :post_id, presence: true
      end
      params_hash = { id: 1 }
      params = params_class.new(params_hash)
      expect(params).to be_invalid
      expect(params.comments.to_a.size).to eq(2)
      expect(params.comments.first.author).to eq('Anonymous')
      expect(params.comments.first.created_at).to eq(Date.today)
      expect(params.comments[-1].author).to eq('Anonymous')
      expect(params.comments[-1].created_at).to eq(Date.today)
    end

    it 'works with inheritance' do
      parent_class = Class.new(EasyParams::Base) do
        has :user, default: {} do
          string :name
          string :role, default: 'guest'
        end
      end

      child_class = Class.new(parent_class) do
        # Child class can extend parent's schema
        user_schema do
          string :email, presence: true
          validates :name, presence: true
        end
      end

      # Test that child class has extended schema
      child_instance = child_class.new(user: { name: 'John', email: 'john@example.com' })
      expect(child_instance.user.name).to eq('John')
      expect(child_instance.user.email).to eq('john@example.com')
      expect(child_instance.user.role).to eq('guest') # Default preserved
      expect(child_instance).to be_valid

      # Test validation works
      invalid_child = child_class.new(user: { name: '', email: 'john@example.com' })
      expect(invalid_child).to be_invalid
      expect(invalid_child.errors[:"user.name"]).to include("can't be blank")

      # Test that parent class is unaffected
      parent_instance = parent_class.new(user: { name: 'Jane' })
      expect(parent_instance.user.name).to eq('Jane')
      expect(parent_instance.user.role).to eq('guest')
      expect(parent_instance.user).not_to respond_to(:email) # Parent doesn't have email
    end
  end
end