# frozen_string_literal: true

require_relative "lib/active_code_first/activerecord/version"

Gem::Specification.new do |spec|
  spec.name = "active_code_first-activerecord"
  spec.version = ActiveCodeFirst::Activerecord::VERSION
  spec.authors = ["ActiveCodeFirst Team"]
  spec.email = ["team@activecodefirst.org"]

  spec.summary = "ActiveRecord adapter for ActiveCodeFirst"
  spec.description = "Enables model-first development flow in Rails with automatic migration generation from ActiveCodeFirst model definitions"
  spec.homepage = "https://github.com/activecodefirst/active_code_first-activerecord"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/README.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null || find . -type f -print0`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_runtime_dependency "active_code_first", "~> 0.1"
  spec.add_runtime_dependency "activerecord", ">= 7.0"
  spec.add_runtime_dependency "railties", ">= 7.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "sqlite3", "~> 1.6"
  spec.add_development_dependency "rails", ">= 7.0"
end
