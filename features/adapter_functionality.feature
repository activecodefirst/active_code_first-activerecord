Feature: ActiveRecord Adapter Functionality
  As a developer using ActiveCodeFirst
  I want the ActiveRecord adapter to work correctly
  So that I can manage database schemas from model definitions

  Scenario: Type mapping
    Given I have an ActiveRecord adapter
    When I map the type "string"
    Then it should return "string"
    When I map the type "integer"
    Then it should return "integer"
    When I map the type "boolean"
    Then it should return "boolean"
    When I map the type "time"
    Then it should return "datetime"

  Scenario: Create table from model
    Given I have a model with attributes:
      | name  | type    |
      | email | string  |
      | age   | integer |
    When I create the table using the adapter
    Then the table should exist in the database
    And the table should have a column "email" of type "string"
    And the table should have a column "age" of type "integer"
    And the table should have timestamps

  Scenario: Generate migration code
    Given I have a model with attributes:
      | name  | type   | options      |
      | title | string | index: true  |
      | body  | text   |              |
    When I generate migration code for the model
    Then the migration should include "create_table"
    And the migration should include "t.string :title"
    And the migration should include "t.text :body"
    And the migration should include "add_index"
    And the migration should include "t.timestamps"

  Scenario: Check table existence
    Given I have a model "TestModel"
    When I check if the table exists
    Then it should return false
    When I create the table using the adapter
    And I check if the table exists
    Then it should return true

  Scenario: Add index to table
    Given I have a model with a table created
    When I add an index on column "email"
    Then the index should exist on the table
    When I add a unique index on column "username"
    Then the unique index should exist on the table
