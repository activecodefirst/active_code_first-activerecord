# frozen_string_literal: true

# Example models demonstrating active_code_first-activerecord usage

# Example 1: Simple User Model
class User < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :email, :string, index: true
  attribute :name, :string
  attribute :age, :integer
  attribute :active, :boolean, default: true
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than: 0, less_than: 120 }, allow_nil: true

  has_many :posts
  has_many :comments
end

# Example 2: Blog Post Model
class Post < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :title, :string, index: true
  attribute :body, :text
  attribute :published_at, :datetime
  attribute :view_count, :integer, default: 0
  attribute :featured, :boolean, default: false
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :body, presence: true

  belongs_to :user
  has_many :comments, dependent: :destroy
end

# Example 3: E-commerce Product Model
class Product < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :name, :string
  attribute :description, :text
  attribute :price, :decimal
  attribute :stock_quantity, :integer
  attribute :active, :boolean, default: true
  attribute :sku, :string, index: true
  attribute :weight, :float
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :sku, uniqueness: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :category
  has_many :order_items
  has_many :reviews
end

# Example 4: Comment Model with Composite Index
class Comment < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :body, :text
  attribute :user_id, :integer
  attribute :post_id, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Composite index for efficient querying
  index :user_post, [:user_id, :post_id]

  validates :body, presence: true, length: { minimum: 1, maximum: 1000 }

  belongs_to :user
  belongs_to :post
end

# Example 5: Category Model with Unique Index
class Category < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :name, :string
  attribute :slug, :string
  attribute :description, :text
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Unique index on slug
  index :unique_slug, [:slug], unique: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  has_many :products
end

# Example 6: Order Model with JSON Data
class Order < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :order_number, :string, index: true
  attribute :status, :string
  attribute :total_amount, :decimal
  attribute :metadata, :json
  attribute :shipped_at, :datetime
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending processing shipped delivered cancelled] }

  belongs_to :user
  has_many :order_items
end

# Example 7: Profile Model with Various Types
class Profile < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :bio, :text
  attribute :avatar_url, :string
  attribute :birth_date, :date
  attribute :website, :string
  attribute :social_links, :json
  attribute :verified, :boolean, default: false
  attribute :follower_count, :integer, default: 0
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :bio, length: { maximum: 500 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  belongs_to :user
end
