# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-17

### Added

- Initial release of active_code_first-activerecord gem
- ActiveRecord adapter implementation for ActiveCodeFirst
- Rails model generator (`rails generate active_code_first:model`)
- Automatic migration generation from model definitions
- Support for all standard ActiveRecord data types
- Index generation (single column and composite)
- Railtie integration for seamless Rails integration
- Rake tasks for schema management:
  - `rake active_code_first:activerecord:generate_migrations`
  - `rake active_code_first:activerecord:sync`
  - `rake active_code_first:activerecord:status`
- Comprehensive RSpec test suite
- Cucumber feature tests for BDD
- Complete documentation and README
- MIT License

### Features

- Model-first development flow
- Type mapping between ActiveCodeFirst and ActiveRecord
- Migration class generation
- Table creation and management
- Index creation (regular and unique)
- Timestamp support
- Namespaced model support
- Skip migration option for generators

### Documentation

- Comprehensive README with examples
- Installation instructions
- Usage guide
- API documentation
- Troubleshooting guide
- Comparison with traditional Rails approach

### Testing

- RSpec unit tests for adapter
- RSpec tests for generator
- Cucumber feature tests for model generation
- Cucumber feature tests for adapter functionality
- Test coverage for all major components

### Requirements

- Ruby >= 3.3.6
- Rails >= 7.0
- ActiveRecord >= 7.0
- active_code_first ~> 0.1

## [Unreleased]

### Planned Features

- Schema change detection and migration generation
- Support for database-specific features (PostgreSQL, MySQL, SQLite)
- Enhanced validation DSL
- Association schema definitions
- Rollback support for schema changes
- Schema versioning
- Database seeding integration
- Performance optimizations

---

[0.1.0]: https://github.com/activecodefirst/active_code_first-activerecord/releases/tag/v0.1.0
