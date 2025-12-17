# frozen_string_literal: true

Given("I have an ActiveRecord adapter") do
  @adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
end

When("I map the type {string}") do |type|
  @mapped_type = @adapter.map_type(type.to_sym)
end

Then("it should return {string}") do |expected_type|
  expect(@mapped_type.to_s).to eq(expected_type)
end

Given("I have a model with attributes:") do |table|
  attributes_schema = {}
  
  table.hashes.each do |row|
    type_class = Class.new do
      define_singleton_method(:name) { row["type"] }
    end
    
    attributes_schema[row["name"].to_sym] = {
      type: type_class,
      index: row["options"]&.include?("index")
    }
  end
  
  @model_class = Class.new(ActiveRecord::Base) do
    self.table_name = "test_table_#{rand(10000)}"
    
    define_singleton_method(:attributes_schema) { attributes_schema }
    define_singleton_method(:indices_schema) { {} }
  end
  
  @adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
end

When("I create the table using the adapter") do
  @adapter.create_table(@model_class)
end

Then("the table should exist in the database") do
  expect(@adapter.table_exists?(@model_class)).to be true
end

Then("the table should have a column {string} of type {string}") do |column_name, column_type|
  columns = ActiveRecord::Base.connection.columns(@model_class.table_name)
  column = columns.find { |c| c.name == column_name }
  
  expect(column).not_to be_nil, "Column #{column_name} not found"
  expect(column.type.to_s).to eq(column_type)
end

Then("the table should have timestamps") do
  columns = ActiveRecord::Base.connection.columns(@model_class.table_name)
  column_names = columns.map(&:name)
  
  expect(column_names).to include("created_at")
  expect(column_names).to include("updated_at")
end

When("I generate migration code for the model") do
  @migration_code = @adapter.generate_create_table_migration(@model_class)
end

Then("the migration should include {string}") do |content|
  expect(@migration_code).to include(content),
    "Expected migration to include '#{content}' but got:\n#{@migration_code}"
end

Given("I have a model {string}") do |model_name|
  @model_class = Class.new(ActiveRecord::Base) do
    self.table_name = model_name.underscore.pluralize
    
    define_singleton_method(:attributes_schema) do
      {
        name: { type: Class.new { def self.name; "string"; end } }
      }
    end
    
    define_singleton_method(:indices_schema) { {} }
  end
  
  @adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
end

When("I check if the table exists") do
  @table_exists = @adapter.table_exists?(@model_class)
end

Then("it should return false") do
  expect(@table_exists).to be false
end

Then("it should return true") do
  expect(@table_exists).to be true
end

Given("I have a model with a table created") do
  attributes_schema = {
    email: { type: Class.new { def self.name; "string"; end } },
    username: { type: Class.new { def self.name; "string"; end } }
  }
  
  @model_class = Class.new(ActiveRecord::Base) do
    self.table_name = "indexed_test_table"
    
    define_singleton_method(:attributes_schema) { attributes_schema }
    define_singleton_method(:indices_schema) { {} }
  end
  
  @adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
  @adapter.create_table(@model_class)
end

When("I add an index on column {string}") do |column_name|
  @adapter.add_index(@model_class, column_name.to_sym)
  @indexed_column = column_name
end

Then("the index should exist on the table") do
  indices = ActiveRecord::Base.connection.indexes(@model_class.table_name)
  index = indices.find { |idx| idx.columns.include?(@indexed_column) }
  
  expect(index).not_to be_nil, "Index on #{@indexed_column} not found"
end

When("I add a unique index on column {string}") do |column_name|
  @adapter.add_index(@model_class, column_name.to_sym, unique: true)
  @unique_indexed_column = column_name
end

Then("the unique index should exist on the table") do
  indices = ActiveRecord::Base.connection.indexes(@model_class.table_name)
  index = indices.find { |idx| idx.columns.include?(@unique_indexed_column) }
  
  expect(index).not_to be_nil, "Unique index on #{@unique_indexed_column} not found"
  expect(index.unique).to be true
end
