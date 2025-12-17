# frozen_string_literal: true

require "active_code_first-activerecord"
require "active_record"
require "sqlite3"

# Configure ActiveRecord for testing
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Load support files
Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset database before each test
  config.before(:each) do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table, if_exists: true)
    end
  end

  # Clean up after tests
  config.after(:suite) do
    ActiveRecord::Base.connection.disconnect!
  end
end
