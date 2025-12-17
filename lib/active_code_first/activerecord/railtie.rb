# frozen_string_literal: true

require "rails/railtie"

module ActiveCodeFirst
  module Activerecord
    class Railtie < Rails::Railtie
      railtie_name :active_code_first_activerecord

      # Load rake tasks
      rake_tasks do
        load File.expand_path("../../../tasks/active_code_first_activerecord.rake", __dir__)
      end

      # Register generators
      generators do
        require "generators/active_code_first/model/model_generator"
      end

      # Initialize configuration
      initializer "active_code_first_activerecord.configure" do
        ActiveCodeFirst.configure do |config|
          config.default_adapter = :active_record
          config.migrations_path ||= Rails.root.join("db", "migrate")
        end
      end

      # Setup after Rails initialization
      config.after_initialize do
        # Ensure adapter is registered
        unless ActiveCodeFirst::Adapter::Registry.registered?(:active_record)
          require "active_code_first/adapter/active_record_adapter"
        end
      end
    end
  end
end
