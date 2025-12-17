# frozen_string_literal: true

namespace :active_code_first do
  namespace :activerecord do
    desc "Generate migrations from all ActiveCodeFirst models"
    task generate_migrations: :environment do
      require "active_code_first-activerecord"
      
      puts "Scanning for ActiveCodeFirst models..."
      
      # Load all models
      Rails.application.eager_load!
      
      # Find all models that include ActiveCodeFirst::Model
      models = ObjectSpace.each_object(Class).select do |klass|
        klass < ActiveRecord::Base && 
        klass.included_modules.include?(ActiveCodeFirst::Model) &&
        !klass.abstract_class?
      end
      
      if models.empty?
        puts "No ActiveCodeFirst models found."
        return
      end
      
      puts "Found #{models.size} model(s): #{models.map(&:name).join(', ')}"
      
      adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
      
      models.each do |model|
        next if adapter.table_exists?(model)
        
        puts "\nGenerating migration for #{model.name}..."
        
        # Generate migration filename
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
        migration_name = "create_#{model.table_name}"
        filename = "#{timestamp}_#{migration_name}.rb"
        filepath = Rails.root.join("db", "migrate", filename)
        
        # Generate migration content
        migration_code = adapter.generate_migration_class(model, migration_name)
        
        # Write migration file
        File.write(filepath, migration_code)
        
        puts "  Created: #{filepath}"
      end
      
      puts "\nDone! Run 'rails db:migrate' to apply migrations."
    end
    
    desc "Sync database schema with model definitions"
    task sync: :environment do
      require "active_code_first-activerecord"
      
      puts "Syncing database schema with ActiveCodeFirst models..."
      
      # Load all models
      Rails.application.eager_load!
      
      # Find all models
      models = ObjectSpace.each_object(Class).select do |klass|
        klass < ActiveRecord::Base && 
        klass.included_modules.include?(ActiveCodeFirst::Model) &&
        !klass.abstract_class?
      end
      
      if models.empty?
        puts "No ActiveCodeFirst models found."
        return
      end
      
      adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
      
      models.each do |model|
        if adapter.table_exists?(model)
          puts "✓ #{model.name} (table exists)"
          # TODO: Check for schema differences and generate update migrations
        else
          puts "✗ #{model.name} (table missing - run generate_migrations)"
        end
      end
      
      puts "\nSync complete!"
    end
    
    desc "Show status of ActiveCodeFirst models"
    task status: :environment do
      require "active_code_first-activerecord"
      
      puts "ActiveCodeFirst Model Status"
      puts "=" * 60
      
      # Load all models
      Rails.application.eager_load!
      
      # Find all models
      models = ObjectSpace.each_object(Class).select do |klass|
        klass < ActiveRecord::Base && 
        klass.included_modules.include?(ActiveCodeFirst::Model) &&
        !klass.abstract_class?
      end
      
      if models.empty?
        puts "No ActiveCodeFirst models found."
        return
      end
      
      adapter = ActiveCodeFirst::Adapter::ActiveRecordAdapter.new
      
      models.each do |model|
        table_exists = adapter.table_exists?(model)
        status = table_exists ? "✓ EXISTS" : "✗ MISSING"
        attributes_count = model.attributes_schema&.size || 0
        
        puts "\n#{model.name}"
        puts "  Table: #{model.table_name} [#{status}]"
        puts "  Attributes: #{attributes_count}"
        
        if model.attributes_schema
          model.attributes_schema.each do |name, schema|
            type = schema[:type].name rescue schema[:type]
            puts "    - #{name}: #{type}"
          end
        end
      end
      
      puts "\n" + "=" * 60
    end
  end
end

# Alias for convenience
namespace :acf do
  namespace :ar do
    task generate: "active_code_first:activerecord:generate_migrations"
    task sync: "active_code_first:activerecord:sync"
    task status: "active_code_first:activerecord:status"
  end
end
