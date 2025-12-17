# ActiveCodeFirst::Activerecord

[![Gem Version](https://badge.fury.io/rb/active_code_first-activerecord.svg)](https://badge.fury.io/rb/active_code_first-activerecord)
[![Build Status](https://github.com/activecodefirst/active_code_first-activerecord/workflows/CI/badge.svg)](https://github.com/activecodefirst/active_code_first-activerecord/actions)

**ActiveRecord adapter for ActiveCodeFirst** - Enable model-first development flow in Ruby on Rails with automatic migration generation.

## Overview

`active_code_first-activerecord` is a Ruby gem that integrates [ActiveCodeFirst](https://github.com/activecodefirst/active_code_first) with Ruby on Rails' ActiveRecord ORM. It enables a **model-first development approach** where you define your data models with complete schema information, and the gem automatically generates the necessary database migrations.

### Traditional Rails vs. Model-First

**Traditional Rails Flow:**
```
1. rails generate migration CreateUsers
2. Edit migration file (add columns, indices)
3. rails db:migrate
4. Create model file
5. Add validations and associations
```

**Model-First Flow (with active_code_first-activerecord):**
```
1. rails generate active_code_first:model User email:string name:string
2. Model file created with schema defined
3. Migration automatically generated
4. rails db:migrate
```

## Features

- ✅ **Model-First Development**: Define schema in models, not migrations
- ✅ **Automatic Migration Generation**: Migrations created from model definitions
- ✅ **Rails Generator**: Familiar `rails generate` command interface
- ✅ **Type Safety**: Built-in type system with validation
- ✅ **Explicit Schema**: All schema information in model code
- ✅ **ActiveRecord Compatible**: Works seamlessly with existing Rails apps
- ✅ **Rake Tasks**: Convenient tasks for schema management

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_code_first-activerecord'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install active_code_first-activerecord
```

## Requirements

- Ruby >= 3.3.6
- Rails >= 7.0
- ActiveRecord >= 7.0

## Quick Start

### 1. Generate a Model

Use the Rails generator to create a model with schema:

```bash
rails generate active_code_first:model User email:string name:string age:integer
```

This creates two files:

**app/models/user.rb:**
```ruby
class User < ApplicationRecord
  include ActiveCodeFirst::Model

  adapter :active_record

  # Attributes
  attribute :email, :string
  attribute :name, :string
  attribute :age, :integer

  # Timestamps
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Add validations here
  # validates :email, presence: true, uniqueness: true

  # Add associations here
  # belongs_to :organization
  # has_many :posts
end
```

**db/migrate/20231201120000_create_users.rb:**
```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
```

### 2. Run Migrations

```bash
rails db:migrate
```

### 3. Use Your Model

```ruby
user = User.new(email: "john@example.com", name: "John Doe", age: 30)
user.save
```

## Usage

### Generating Models

#### Basic Model

```bash
rails generate active_code_first:model Product name:string price:decimal
```

#### Model with Indexed Attributes

```bash
rails generate active_code_first:model Post title:string:index body:text
```

This creates an index on the `title` column:

```ruby
attribute :title, :string, index: true
```

And in the migration:

```ruby
add_index :posts, :title
```

#### Model with Different Data Types

```bash
rails generate active_code_first:model Article \
  title:string \
  body:text \
  published_at:datetime \
  view_count:integer \
  featured:boolean \
  rating:decimal
```

#### Skip Migration Generation

```bash
rails generate active_code_first:model Comment body:text --skip-migration
```

#### Namespaced Models

```bash
rails generate active_code_first:model Admin::User email:string role:string
```

Creates: `app/models/admin/user.rb`

### Supported Data Types

| Type      | Ruby Class                    | Database Type |
|-----------|-------------------------------|---------------|
| `:string` | String                        | VARCHAR       |
| `:text`   | String                        | TEXT          |
| `:integer`| Integer                       | INTEGER       |
| `:decimal`| BigDecimal                    | DECIMAL       |
| `:float`  | Float                         | FLOAT         |
| `:boolean`| TrueClass, FalseClass         | BOOLEAN       |
| `:datetime`| Time, DateTime               | DATETIME      |
| `:date`   | Date                          | DATE          |
| `:binary` | String (binary)               | BLOB          |
| `:json`   | Hash, Array                   | JSON          |

### Adding Validations

Edit your model to add validations:

```ruby
class User < ApplicationRecord
  include ActiveCodeFirst::Model

  adapter :active_record

  attribute :email, :string, index: true
  attribute :age, :integer

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than: 120 }
end
```

### Adding Associations

ActiveCodeFirst models work with standard ActiveRecord associations:

```ruby
class User < ApplicationRecord
  include ActiveCodeFirst::Model

  adapter :active_record

  attribute :email, :string

  has_many :posts
  has_many :comments
  belongs_to :organization, optional: true
end
```

### Defining Indices

#### Single Column Index

```ruby
attribute :email, :string, index: true
```

#### Composite Index

```ruby
attribute :email, :string
attribute :username, :string

index :email_username, [:email, :username]
```

#### Unique Index

```ruby
attribute :email, :string

index :unique_email, [:email], unique: true
```

## Rake Tasks

### Generate Migrations from Models

Scan all ActiveCodeFirst models and generate migrations for tables that don't exist:

```bash
rake active_code_first:activerecord:generate_migrations
# or shorthand:
rake acf:ar:generate
```

### Check Model Status

View the status of all ActiveCodeFirst models:

```bash
rake active_code_first:activerecord:status
# or shorthand:
rake acf:ar:status
```

Output:
```
ActiveCodeFirst Model Status
============================================================

User
  Table: users [✓ EXISTS]
  Attributes: 3
    - email: string
    - name: string
    - age: integer

Post
  Table: posts [✗ MISSING]
  Attributes: 2
    - title: string
    - body: text
```

### Sync Database Schema

Check which models have tables and which don't:

```bash
rake active_code_first:activerecord:sync
# or shorthand:
rake acf:ar:sync
```

## Configuration

ActiveCodeFirst is automatically configured to use the ActiveRecord adapter when you include this gem. You can customize the configuration in an initializer:

**config/initializers/active_code_first.rb:**

```ruby
ActiveCodeFirst.configure do |config|
  # Default adapter (automatically set to :active_record)
  config.default_adapter = :active_record

  # Migrations path
  config.migrations_path = Rails.root.join("db", "migrate")

  # Logger
  config.logger = Rails.logger
end
```

## Advanced Usage

### Custom Migration Generation

You can programmatically generate migrations using the adapter:

```ruby
adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
migration_code = adapter.generate_migration_class(User, "create_users")

puts migration_code
```

### Check Table Existence

```ruby
adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new

if adapter.table_exists?(User)
  puts "Users table exists"
else
  puts "Users table does not exist"
end
```

### Create Table Programmatically

```ruby
adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
adapter.create_table(User)
```

## Examples

### E-commerce Application

```ruby
# app/models/product.rb
class Product < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :name, :string
  attribute :description, :text
  attribute :price, :decimal
  attribute :stock_quantity, :integer
  attribute :active, :boolean, default: true
  attribute :sku, :string, index: true

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :sku, uniqueness: true

  has_many :order_items
  belongs_to :category
end
```

```bash
rails generate active_code_first:model Product \
  name:string \
  description:text \
  price:decimal \
  stock_quantity:integer \
  active:boolean \
  sku:string:index
```

### Blog Application

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :title, :string, index: true
  attribute :body, :text
  attribute :published_at, :datetime
  attribute :view_count, :integer, default: 0
  attribute :featured, :boolean, default: false

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :body, presence: true

  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
end
```

## Testing

The gem includes comprehensive test coverage using RSpec and Cucumber.

### Run All Tests

```bash
bundle exec rake
```

### Run RSpec Tests Only

```bash
bundle exec rspec
```

### Run Cucumber Tests Only

```bash
bundle exec cucumber
```

## Architecture

### Components

1. **ActiveRecordAdapter**: Translates ActiveCodeFirst models to ActiveRecord operations
2. **ModelGenerator**: Rails generator for creating models with schema
3. **Railtie**: Integrates with Rails framework
4. **Rake Tasks**: Convenient command-line tools

### How It Works

1. You define a model using the ActiveCodeFirst DSL
2. The adapter reads the model's `attributes_schema` and `indices_schema`
3. Migration code is generated based on the schema
4. ActiveRecord executes the migration to create/modify database tables

## Comparison with Traditional Rails

### Traditional Approach

```ruby
# db/migrate/20231201000000_create_users.rb
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.integer :age
      t.timestamps
    end
    add_index :users, :email
  end
end

# app/models/user.rb
class User < ApplicationRecord
  validates :email, presence: true
end
```

### Model-First Approach

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include ActiveCodeFirst::Model
  adapter :active_record

  attribute :email, :string, index: true
  attribute :name, :string
  attribute :age, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :email, presence: true
end

# Migration generated automatically!
```

## Benefits

1. **Single Source of Truth**: Schema defined in one place (the model)
2. **Reduced Boilerplate**: No need to write migrations manually
3. **Type Safety**: Explicit type definitions with validation
4. **Better Documentation**: Model file shows complete schema
5. **Easier Refactoring**: Change schema in model, regenerate migration
6. **Consistency**: Same patterns across all models

## Limitations

- **Schema Changes**: Currently best for new models; updating existing schemas requires manual migrations
- **Complex Migrations**: Data transformations still need manual migrations
- **Learning Curve**: Developers need to understand both ActiveCodeFirst and ActiveRecord

## Troubleshooting

### Generator Not Found

If you get "Could not find generator 'active_code_first:model'":

1. Ensure the gem is in your Gemfile and installed
2. Restart your Rails server
3. Run `rails generate` to see available generators

### Migration Not Generated

If the migration file isn't created:

1. Check that you didn't use `--skip-migration` flag
2. Ensure `db/migrate` directory exists
3. Check file permissions

### Table Already Exists

If you get "Table already exists" error:

1. Check `rake acf:ar:status` to see existing tables
2. Use `--skip-migration` if table already exists
3. Manually create a migration for schema changes

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/activecodefirst/active_code_first-activerecord.

### Development Setup

```bash
git clone https://github.com/activecodefirst/active_code_first-activerecord.git
cd active_code_first-activerecord
bundle install
bundle exec rake
```

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Credits

- Built on top of [ActiveCodeFirst](https://github.com/activecodefirst/active_code_first)
- Inspired by Entity Framework's Code First approach
- Follows Rails conventions and best practices

## Support

- **Documentation**: [GitHub Repository](https://github.com/activecodefirst/active_code_first-activerecord)
- **Issues**: [GitHub Issues](https://github.com/activecodefirst/active_code_first-activerecord/issues)
- **Discussions**: [GitHub Discussions](https://github.com/activecodefirst/active_code_first-activerecord/discussions)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

**Made with ❤️ for the Ruby on Rails community**
