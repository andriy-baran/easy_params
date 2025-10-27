RSpec.describe EasyParams do
  describe 'override validations' do
    let(:params_class) do
      Class.new(EasyParams::Base) do
        integer :id, presence: true
        has :post, default: { published_at: Date.today } do
          integer :id
          string :title
          string :content
          date :published_at
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
  end
end