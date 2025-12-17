# frozen_string_literal: true

require "active_record"

module ActiveCodeFirst
  module Adapter
    class ActiveRecordAdapter < Base
      # Map ActiveCodeFirst types to ActiveRecord column types
      def map_type(type)
        case type.to_sym
        when :string then :string
        when :integer then :integer
        when :boolean then :boolean
        when :time then :datetime
        when :text then :text
        when :decimal then :decimal
        when :float then :float
        when :date then :date
        when :binary then :binary
        when :json then :json
        else type
        end
      end

      # Generate migration code for creating a table from model
      def generate_create_table_migration(model_class)
        table_name = model_class.table_name
        attributes = model_class.attributes_schema || {}
        indices = model_class.indices_schema || {}

        migration_code = []
        migration_code << "create_table :#{table_name} do |t|"

        # Add columns
        attributes.each do |name, schema|
          next if name == :id # Skip id, it's created automatically

          column_type = map_type(schema[:type].name)
          options = build_column_options(schema)
          
          migration_code << "  t.#{column_type} :#{name}#{options}"
        end

        # Add timestamps if not explicitly defined
        unless attributes.key?(:created_at) && attributes.key?(:updated_at)
          migration_code << ""
          migration_code << "  t.timestamps"
        end

        migration_code << "end"

        # Add indices
        indices.each do |index_name, index_schema|
          columns = index_schema[:columns]
          index_options = build_index_options(index_schema)
          
          if columns.is_a?(Array) && columns.size > 1
            migration_code << ""
            migration_code << "add_index :#{table_name}, #{columns.inspect}#{index_options}"
          elsif columns.is_a?(Array)
            migration_code << ""
            migration_code << "add_index :#{table_name}, :#{columns.first}#{index_options}"
          else
            migration_code << ""
            migration_code << "add_index :#{table_name}, :#{columns}#{index_options}"
          end
        end

        # Add single-column indices from attributes
        attributes.each do |name, schema|
          if schema[:index] && !indices.values.any? { |idx| idx[:columns] == [name] || idx[:columns] == name }
            migration_code << ""
            migration_code << "add_index :#{table_name}, :#{name}"
          end
        end

        migration_code.join("\n")
      end

      # Generate migration class code
      def generate_migration_class(model_class, migration_name)
        table_name = model_class.table_name
        class_name = migration_name.camelize
        
        migration_body = generate_create_table_migration(model_class)
        
        <<~RUBY
          class #{class_name} < ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]
            def change
              #{migration_body.split("\n").join("\n    ")}
            end
          end
        RUBY
      end

      # Build column options string
      def build_column_options(schema)
        options = []
        
        options << "null: false" if schema[:required]
        options << "default: #{schema[:default].inspect}" if schema.key?(:default)
        options << "limit: #{schema[:limit]}" if schema[:limit]
        options << "precision: #{schema[:precision]}" if schema[:precision]
        options << "scale: #{schema[:scale]}" if schema[:scale]
        
        options.empty? ? "" : ", #{options.join(', ')}"
      end

      # Build index options string
      def build_index_options(index_schema)
        options = []
        
        options << "unique: true" if index_schema[:unique]
        options << "name: '#{index_schema[:name]}'" if index_schema[:name]
        
        options.empty? ? "" : ", #{options.join(', ')}"
      end

      # Create table in database
      def create_table(model_class)
        table_name = model_class.table_name
        attributes = model_class.attributes_schema || {}

        ActiveRecord::Base.connection.create_table(table_name) do |t|
          attributes.each do |name, schema|
            next if name == :id

            column_type = map_type(schema[:type].name)
            column_options = extract_column_options(schema)
            
            t.send(column_type, name, **column_options)
          end

          unless attributes.key?(:created_at) && attributes.key?(:updated_at)
            t.timestamps
          end
        end
      end

      # Add index to table
      def add_index(model_class, column_names, **options)
        table_name = model_class.table_name
        ActiveRecord::Base.connection.add_index(table_name, column_names, **options)
      end

      # Drop table from database
      def drop_table(model_class)
        table_name = model_class.table_name
        ActiveRecord::Base.connection.drop_table(table_name)
      end

      # Check if table exists
      def table_exists?(model_class)
        table_name = model_class.table_name
        ActiveRecord::Base.connection.table_exists?(table_name)
      end

      private

      def extract_column_options(schema)
        options = {}
        
        options[:null] = false if schema[:required]
        options[:default] = schema[:default] if schema.key?(:default)
        options[:limit] = schema[:limit] if schema[:limit]
        options[:precision] = schema[:precision] if schema[:precision]
        options[:scale] = schema[:scale] if schema[:scale]
        
        options
      end
    end
  end
end

# Register the adapter
ActiveCodeFirst::Adapter::Registry.register(:active_record, ActiveCodeFirst::Adapter::ActiveRecordAdapter)
