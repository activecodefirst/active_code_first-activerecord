# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveCodeFirst::Adapter::ActiveRecordAdapter do
  subject(:adapter) { described_class.new }

  describe "#map_type" do
    it "maps string to string" do
      expect(adapter.map_type(:string)).to eq(:string)
    end

    it "maps integer to integer" do
      expect(adapter.map_type(:integer)).to eq(:integer)
    end

    it "maps boolean to boolean" do
      expect(adapter.map_type(:boolean)).to eq(:boolean)
    end

    it "maps time to datetime" do
      expect(adapter.map_type(:time)).to eq(:datetime)
    end

    it "maps text to text" do
      expect(adapter.map_type(:text)).to eq(:text)
    end

    it "maps decimal to decimal" do
      expect(adapter.map_type(:decimal)).to eq(:decimal)
    end

    it "returns unknown types as-is" do
      expect(adapter.map_type(:custom_type)).to eq(:custom_type)
    end
  end

  describe "#generate_create_table_migration" do
    let(:mock_type) do
      Class.new do
        def self.name
          "string"
        end
      end
    end

    let(:model_class) do
      Class.new do
        def self.table_name
          "users"
        end

        def self.attributes_schema
          {
            id: { type: mock_type, primary_key: true },
            email: { type: mock_type, index: true },
            name: { type: mock_type },
            age: { type: Class.new { def self.name; "integer"; end } }
          }
        end

        def self.indices_schema
          {}
        end
      end
    end

    it "generates migration code for creating table" do
      migration = adapter.generate_create_table_migration(model_class)

      expect(migration).to include("create_table :users")
      expect(migration).to include("t.string :email")
      expect(migration).to include("t.string :name")
      expect(migration).to include("t.integer :age")
      expect(migration).to include("t.timestamps")
    end

    it "includes index for indexed attributes" do
      migration = adapter.generate_create_table_migration(model_class)

      expect(migration).to include("add_index :users, :email")
    end

    it "does not include id column (auto-generated)" do
      migration = adapter.generate_create_table_migration(model_class)

      expect(migration).not_to include("t.string :id")
      expect(migration).not_to include("t.integer :id")
    end
  end

  describe "#generate_migration_class" do
    let(:mock_type) do
      Class.new do
        def self.name
          "string"
        end
      end
    end

    let(:model_class) do
      Class.new do
        def self.table_name
          "posts"
        end

        def self.attributes_schema
          {
            title: { type: mock_type },
            body: { type: Class.new { def self.name; "text"; end } }
          }
        end

        def self.indices_schema
          {}
        end
      end
    end

    it "generates complete migration class" do
      migration = adapter.generate_migration_class(model_class, "create_posts")

      expect(migration).to include("class CreatePosts < ActiveRecord::Migration")
      expect(migration).to include("def change")
      expect(migration).to include("create_table :posts")
      expect(migration).to include("end")
    end

    it "includes migration version" do
      migration = adapter.generate_migration_class(model_class, "create_posts")

      expect(migration).to match(/ActiveRecord::Migration\[\d+\.\d+\]/)
    end
  end

  describe "#build_column_options" do
    it "returns empty string for no options" do
      schema = { type: "string" }
      expect(adapter.send(:build_column_options, schema)).to eq("")
    end

    it "includes null: false for required fields" do
      schema = { type: "string", required: true }
      expect(adapter.send(:build_column_options, schema)).to include("null: false")
    end

    it "includes default value" do
      schema = { type: "boolean", default: false }
      expect(adapter.send(:build_column_options, schema)).to include("default: false")
    end

    it "includes limit" do
      schema = { type: "string", limit: 255 }
      expect(adapter.send(:build_column_options, schema)).to include("limit: 255")
    end

    it "combines multiple options" do
      schema = { type: "string", required: true, default: "test", limit: 100 }
      options = adapter.send(:build_column_options, schema)
      
      expect(options).to include("null: false")
      expect(options).to include('default: "test"')
      expect(options).to include("limit: 100")
    end
  end

  describe "#build_index_options" do
    it "returns empty string for no options" do
      schema = { columns: [:email] }
      expect(adapter.send(:build_index_options, schema)).to eq("")
    end

    it "includes unique: true for unique indices" do
      schema = { columns: [:email], unique: true }
      expect(adapter.send(:build_index_options, schema)).to include("unique: true")
    end

    it "includes custom index name" do
      schema = { columns: [:email], name: "idx_users_email" }
      expect(adapter.send(:build_index_options, schema)).to include("name: 'idx_users_email'")
    end
  end

  describe "database operations" do
    let(:mock_type) do
      Class.new do
        def self.name
          "string"
        end
      end
    end

    let(:model_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = "test_models"

        def self.attributes_schema
          {
            name: { type: Class.new { def self.name; "string"; end } },
            age: { type: Class.new { def self.name; "integer"; end } }
          }
        end

        def self.indices_schema
          {}
        end
      end
    end

    describe "#create_table" do
      it "creates table in database" do
        adapter.create_table(model_class)

        expect(ActiveRecord::Base.connection.table_exists?("test_models")).to be true
      end

      it "creates columns from attributes" do
        adapter.create_table(model_class)

        columns = ActiveRecord::Base.connection.columns("test_models").map(&:name)
        expect(columns).to include("name", "age")
      end

      it "adds timestamps by default" do
        adapter.create_table(model_class)

        columns = ActiveRecord::Base.connection.columns("test_models").map(&:name)
        expect(columns).to include("created_at", "updated_at")
      end
    end

    describe "#table_exists?" do
      it "returns false when table does not exist" do
        expect(adapter.table_exists?(model_class)).to be false
      end

      it "returns true when table exists" do
        adapter.create_table(model_class)
        expect(adapter.table_exists?(model_class)).to be true
      end
    end

    describe "#drop_table" do
      it "drops existing table" do
        adapter.create_table(model_class)
        expect(adapter.table_exists?(model_class)).to be true

        adapter.drop_table(model_class)
        expect(adapter.table_exists?(model_class)).to be false
      end
    end

    describe "#add_index" do
      before do
        adapter.create_table(model_class)
      end

      it "adds index to table" do
        adapter.add_index(model_class, :name)

        indices = ActiveRecord::Base.connection.indexes("test_models")
        expect(indices.map(&:columns).flatten).to include("name")
      end

      it "supports unique indices" do
        adapter.add_index(model_class, :name, unique: true)

        indices = ActiveRecord::Base.connection.indexes("test_models")
        unique_index = indices.find { |idx| idx.columns.include?("name") }
        expect(unique_index.unique).to be true
      end
    end
  end
end
