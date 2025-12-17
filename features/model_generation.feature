Feature: Model Generation
  As a Rails developer
  I want to generate models with schema definitions
  So that migrations are automatically created

  Scenario: Generate a simple model
    When I generate a model "User" with attributes "email:string name:string"
    Then a model file should exist at "app/models/user.rb"
    And the model should include "ActiveCodeFirst::Model"
    And the model should include "adapter :active_record"
    And the model should include "attribute :email, :string"
    And the model should include "attribute :name, :string"
    And a migration file should exist for "create_users"
    And the migration should include "create_table :users"
    And the migration should include "t.string :email"
    And the migration should include "t.string :name"

  Scenario: Generate a model with indexed attributes
    When I generate a model "Post" with attributes "title:string:index body:text"
    Then a model file should exist at "app/models/post.rb"
    And the model should include "attribute :title, :string, index: true"
    And the model should include "attribute :body, :string"
    And a migration file should exist for "create_posts"
    And the migration should include "add_index :posts, :title"

  Scenario: Generate a model with different data types
    When I generate a model "Product" with attributes "name:string price:decimal quantity:integer active:boolean"
    Then a model file should exist at "app/models/product.rb"
    And the model should include "attribute :name, :string"
    And the model should include "attribute :price, :decimal"
    And the model should include "attribute :quantity, :integer"
    And the model should include "attribute :active, :boolean"
    And a migration file should exist for "create_products"
    And the migration should include "t.string :name"
    And the migration should include "t.decimal :price"
    And the migration should include "t.integer :quantity"
    And the migration should include "t.boolean :active"

  Scenario: Generate a model with timestamps
    When I generate a model "Article" with attributes "title:string"
    Then the model should include "attribute :created_at, :datetime"
    And the model should include "attribute :updated_at, :datetime"
    And the migration should include "t.timestamps"

  Scenario: Generate a model without migration
    When I generate a model "Comment" with attributes "body:text" and option "--skip-migration"
    Then a model file should exist at "app/models/comment.rb"
    And no migration file should exist for "create_comments"

  Scenario: Generate a namespaced model
    When I generate a model "Admin::User" with attributes "email:string"
    Then a model file should exist at "app/models/admin/user.rb"
    And the model should include "module Admin"
    And the model should include "class User"
