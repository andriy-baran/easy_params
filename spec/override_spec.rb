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
  end
end