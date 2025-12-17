# frozen_string_literal: true

require "generators/active_code_first/model/model_generator"

When("I generate a model {string} with attributes {string}") do |model_name, attributes|
  args = [model_name] + attributes.split
  @generator_output = capture_generator_output do
    ActiveCodeFirst::Generators::ModelGenerator.start(args, destination: TEST_TMP_DIR)
  end
  @model_name = model_name
  @table_name = model_name.underscore.pluralize
end

When("I generate a model {string} with attributes {string} and option {string}") do |model_name, attributes, option|
  args = [model_name] + attributes.split + [option]
  @generator_output = capture_generator_output do
    ActiveCodeFirst::Generators::ModelGenerator.start(args, destination: TEST_TMP_DIR)
  end
  @model_name = model_name
  @table_name = model_name.underscore.pluralize
end

Then("a model file should exist at {string}") do |file_path|
  full_path = File.join(TEST_TMP_DIR, file_path)
  expect(File.exist?(full_path)).to be true, "Expected file #{full_path} to exist"
  @model_file_path = full_path
end

Then("the model should include {string}") do |content|
  model_content = File.read(@model_file_path)
  expect(model_content).to include(content), 
    "Expected model to include '#{content}' but got:\n#{model_content}"
end

Then("a migration file should exist for {string}") do |migration_name|
  migration_pattern = File.join(TEST_TMP_DIR, "db", "migrate", "*_#{migration_name}.rb")
  migration_files = Dir.glob(migration_pattern)
  
  expect(migration_files).not_to be_empty, 
    "Expected migration file matching #{migration_pattern} to exist"
  
  @migration_file_path = migration_files.first
end

Then("the migration should include {string}") do |content|
  migration_content = File.read(@migration_file_path)
  expect(migration_content).to include(content),
    "Expected migration to include '#{content}' but got:\n#{migration_content}"
end

Then("no migration file should exist for {string}") do |migration_name|
  migration_pattern = File.join(TEST_TMP_DIR, "db", "migrate", "*_#{migration_name}.rb")
  migration_files = Dir.glob(migration_pattern)
  
  expect(migration_files).to be_empty,
    "Expected no migration file for #{migration_name} but found: #{migration_files.join(', ')}"
end

# Helper methods
def capture_generator_output
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = old_stdout
end

# Add String methods for Rails-like behavior
class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end

  def pluralize
    return self if self.empty?
    
    # Simple pluralization rules
    case self
    when /y$/
      sub(/y$/, 'ies')
    when /s$/, /x$/, /ch$/, /sh$/
      self + 'es'
    else
      self + 's'
    end
  end
end
