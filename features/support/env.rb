# frozen_string_literal: true

require "active_code_first-activerecord"
require "active_record"
require "sqlite3"
require "fileutils"
require "tmpdir"

# Setup test database
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Create temporary directory for generated files
TEST_TMP_DIR = File.expand_path("../../tmp/cucumber", __dir__)
FileUtils.mkdir_p(TEST_TMP_DIR)

Before do
  # Clean up test directory
  FileUtils.rm_rf(TEST_TMP_DIR)
  FileUtils.mkdir_p(TEST_TMP_DIR)
  FileUtils.mkdir_p(File.join(TEST_TMP_DIR, "app", "models"))
  FileUtils.mkdir_p(File.join(TEST_TMP_DIR, "db", "migrate"))
  
  # Reset database
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table, if_exists: true)
  end
  
  # Store original directory
  @original_dir = Dir.pwd
  Dir.chdir(TEST_TMP_DIR)
end

After do
  # Return to original directory
  Dir.chdir(@original_dir) if @original_dir
end

at_exit do
  # Clean up after all tests
  FileUtils.rm_rf(TEST_TMP_DIR) if File.exist?(TEST_TMP_DIR)
end
