# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module ActiveCodeFirst
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :skip_migration, type: :boolean, default: false, desc: "Skip migration generation"
      class_option :parent, type: :string, desc: "The parent class for the generated model"
      class_option :timestamps, type: :boolean, default: true, desc: "Add timestamps (created_at, updated_at)"

      def create_model_file
        template "model.rb.erb", File.join("app/models", class_path, "#{file_name}.rb")
      end

      def create_migration_file
        return if options[:skip_migration]
        
        migration_template "migration.rb.erb",
                          File.join(db_migrate_path, "create_#{table_name}.rb"),
                          migration_version: migration_version
      end

      private

      def parent_class_name
        options[:parent] || "ApplicationRecord"
      end

      def migration_version
        "[#{ActiveRecord::Migration.current_version}]"
      end

      def db_migrate_path
        "db/migrate"
      end

      def parsed_attributes
        @parsed_attributes ||= attributes.map do |attr|
          parse_attribute(attr)
        end
      end

      def parse_attribute(attr)
        name, type_with_options = attr.name.split(":")
        type = type_with_options || "string"
        
        # Check for index suffix
        has_index = name.end_with?("_index") || type.end_with?(":index")
        name = name.gsub(/_index$/, "") if name.end_with?("_index")
        type = type.gsub(/:index$/, "") if type.end_with?(":index")

        # Handle references
        if type == "references" || type == "belongs_to"
          type = "integer"
          name = "#{name}_id" unless name.end_with?("_id")
        end

        AttributeDefinition.new(name, type, has_index, attr.has_uniq_index?)
      end

      def regular_attributes
        parsed_attributes.reject { |attr| attr.name == "id" }
      end

      def indexed_attributes
        parsed_attributes.select(&:index?)
      end

      def table_name
        @table_name ||= name.underscore.pluralize
      end

      class AttributeDefinition
        attr_reader :name, :type, :index, :unique

        def initialize(name, type, index = false, unique = false)
          @name = name
          @type = normalize_type(type)
          @index = index
          @unique = unique
        end

        def index?
          @index
        end

        def unique?
          @unique
        end

        def options_string
          options = []
          options << "index: true" if index?
          options << "unique: true" if unique?
          options.empty? ? "" : ", #{options.join(', ')}"
        end

        def migration_options
          options = []
          options << "null: false" if required?
          options << "default: #{default_value}" if has_default?
          options.empty? ? "" : ", #{options.join(', ')}"
        end

        def required?
          false # Can be enhanced based on conventions
        end

        def has_default?
          type == "boolean"
        end

        def default_value
          case type
          when "boolean" then "false"
          else nil
          end
        end

        private

        def normalize_type(type)
          case type.to_s.downcase
          when "string", "text" then "string"
          when "integer", "int" then "integer"
          when "boolean", "bool" then "boolean"
          when "datetime", "time", "timestamp" then "datetime"
          when "date" then "date"
          when "decimal", "numeric" then "decimal"
          when "float", "double" then "float"
          when "binary", "blob" then "binary"
          when "json", "jsonb" then "json"
          else type
          end
        end
      end
    end
  end
end
