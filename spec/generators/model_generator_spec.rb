# frozen_string_literal: true

require "spec_helper"
require "generators/active_code_first/model/model_generator"
require "rails/generators/test_case"
require "fileutils"

RSpec.describe ActiveCodeFirst::Generators::ModelGenerator, type: :generator do
  destination File.expand_path("../../tmp/generator_test", __dir__)

  before(:all) do
    FileUtils.mkdir_p(destination_root)
  end

  before do
    prepare_destination
  end

  after(:all) do
    FileUtils.rm_rf(File.expand_path("../../tmp", __dir__))
  end

  describe "model generation" do
    it "generates model file" do
      run_generator ["User", "email:string", "name:string"]

      expect(file("app/models/user.rb")).to exist
    end

    it "includes ActiveCodeFirst::Model" do
      run_generator ["User", "email:string"]

      expect(file("app/models/user.rb")).to contain("include ActiveCodeFirst::Model")
    end

    it "sets adapter to active_record" do
      run_generator ["User", "email:string"]

      expect(file("app/models/user.rb")).to contain("adapter :active_record")
    end

    it "generates attributes from arguments" do
      run_generator ["User", "email:string", "age:integer"]

      model_content = file("app/models/user.rb")
      expect(model_content).to contain("attribute :email, :string")
      expect(model_content).to contain("attribute :age, :integer")
    end

    it "handles indexed attributes" do
      run_generator ["User", "email:string:index"]

      expect(file("app/models/user.rb")).to contain("attribute :email, :string, index: true")
    end

    it "includes timestamps by default" do
      run_generator ["User", "email:string"]

      model_content = file("app/models/user.rb")
      expect(model_content).to contain("attribute :created_at, :datetime")
      expect(model_content).to contain("attribute :updated_at, :datetime")
    end

    it "includes validation placeholders" do
      run_generator ["User", "email:string"]

      model_content = file("app/models/user.rb")
      expect(model_content).to contain("# Add validations here")
      expect(model_content).to contain("# validates")
    end

    it "includes association placeholders" do
      run_generator ["User", "email:string"]

      model_content = file("app/models/user.rb")
      expect(model_content).to contain("# Add associations here")
      expect(model_content).to contain("# belongs_to")
      expect(model_content).to contain("# has_many")
    end
  end

  describe "migration generation" do
    it "generates migration file" do
      run_generator ["User", "email:string", "name:string"]

      migration_files = Dir[file("db/migrate/*_create_users.rb")]
      expect(migration_files).not_to be_empty
    end

    it "includes create_table statement" do
      run_generator ["User", "email:string"]

      migration_file = Dir[file("db/migrate/*_create_users.rb")].first
      migration_content = File.read(migration_file)
      
      expect(migration_content).to include("create_table :users")
    end

    it "includes column definitions" do
      run_generator ["User", "email:string", "age:integer"]

      migration_file = Dir[file("db/migrate/*_create_users.rb")].first
      migration_content = File.read(migration_file)
      
      expect(migration_content).to include("t.string :email")
      expect(migration_content).to include("t.integer :age")
    end

    it "includes timestamps" do
      run_generator ["User", "email:string"]

      migration_file = Dir[file("db/migrate/*_create_users.rb")].first
      migration_content = File.read(migration_file)
      
      expect(migration_content).to include("t.timestamps")
    end

    it "includes indices for indexed attributes" do
      run_generator ["User", "email:string:index"]

      migration_file = Dir[file("db/migrate/*_create_users.rb")].first
      migration_content = File.read(migration_file)
      
      expect(migration_content).to include("add_index :users, :email")
    end

    it "skips migration when --skip-migration is passed" do
      run_generator ["User", "email:string", "--skip-migration"]

      migration_files = Dir[file("db/migrate/*_create_users.rb")]
      expect(migration_files).to be_empty
    end
  end

  describe "attribute parsing" do
    it "handles string type" do
      run_generator ["User", "name:string"]

      expect(file("app/models/user.rb")).to contain("attribute :name, :string")
    end

    it "handles integer type" do
      run_generator ["User", "age:integer"]

      expect(file("app/models/user.rb")).to contain("attribute :age, :integer")
    end

    it "handles boolean type" do
      run_generator ["User", "active:boolean"]

      expect(file("app/models/user.rb")).to contain("attribute :active, :boolean")
    end

    it "handles datetime type" do
      run_generator ["User", "published_at:datetime"]

      expect(file("app/models/user.rb")).to contain("attribute :published_at, :datetime")
    end

    it "handles text type" do
      run_generator ["User", "bio:text"]

      expect(file("app/models/user.rb")).to contain("attribute :bio, :string")
    end

    it "defaults to string when no type specified" do
      run_generator ["User", "name"]

      expect(file("app/models/user.rb")).to contain("attribute :name, :string")
    end
  end

  describe "namespaced models" do
    it "generates namespaced model file" do
      run_generator ["Admin::User", "email:string"]

      expect(file("app/models/admin/user.rb")).to exist
    end

    it "includes proper module namespacing" do
      run_generator ["Admin::User", "email:string"]

      model_content = file("app/models/admin/user.rb")
      expect(model_content).to contain("module Admin")
      expect(model_content).to contain("class User")
    end
  end

  # Helper methods
  def run_generator(args)
    # Mock Rails.root
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root)) if defined?(Rails)
    
    # Run the generator
    ActiveCodeFirst::Generators::ModelGenerator.start(args, destination: destination_root)
  end

  def file(path)
    File.new(File.join(destination_root, path))
  end

  def prepare_destination
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(File.join(destination_root, "app/models"))
    FileUtils.mkdir_p(File.join(destination_root, "db/migrate"))
  end
end

# Extend File class for testing
class File
  def exist?
    File.exist?(path)
  end

  def contain(text)
    File.read(path).include?(text)
  end
end
