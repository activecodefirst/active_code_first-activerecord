# frozen_string_literal: true

require_relative "active_code_first/activerecord/version"
require "active_code_first"
require "active_record"
require "rails"

# Load the adapter
require_relative "active_code_first/adapter/active_record_adapter"

# Load Railtie if Rails is present
require_relative "active_code_first/activerecord/railtie" if defined?(Rails)

module ActiveCodeFirst
  module Activerecord
    class Error < StandardError; end

    # Configure ActiveCodeFirst to use ActiveRecord adapter by default
    def self.setup
      ActiveCodeFirst.configure do |config|
        config.default_adapter = :active_record
      end
    end
  end
end

# Auto-setup when loaded
ActiveCodeFirst::Activerecord.setup
