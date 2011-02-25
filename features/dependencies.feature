Feature: dependencies
  As a Tracks user
  In order to keep track of complex todos
  I want to assign and manage todo dependencies

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @selenium
  Scenario: Adding dependency to dependency by drag and drop
    Given I have a project "dependencies" with 3 todos
    And "Todo 2" depends on "Todo 1"
    When I visit the "dependencies" project
    And I drag "Todo 3" to "Todo 2"
    Then the successors of "Todo 1" should include "Todo 2"
    And the successors of "Todo 2" should include "Todo 3"
    When I expand the dependencies of "Todo 1"
    Then I should see "Todo 2" within the dependencies of "Todo 1"
    And I should see "Todo 3" within the dependencies of "Todo 1"
    When I expand the dependencies of "Todo 2"
    Then I should see "Todo 3" within the dependencies of "Todo 2"

  @selenium @wip
  Scenario: Adding dependency with comma to todo   # for #975
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test,1, 2,3 | @pc     |
      | test me     | @pc     |
    When I visit the "dependencies" project
    And I drag "test me" to "test,1, 2,3"
    Then the successors of "test,1, 2,3" should include "test me"
    When I edit the dependency of "test me" to "'test,1, 2,3' <'@pc'; 'dependencies'>,'test,1, 2,3' <'@pc'; 'dependencies'>"
    Then there should not be an error

  Scenario: Deleting a predecessor will activate successors
    Given this is a pending scenario

  @selenium @wip
  Scenario: I can edit a todo to add the todo as a dependency to another
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    When I visit the "dependencies" project
    When I edit the dependency of "test 1" to "'test 2' <'@pc'; 'dependencies'>"
    Then I should see "test 1" within the dependencies of "test 2"
    And I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to "'test 2' <'@pc'; 'dependencies'>, 'test 3' <'@pc'; 'dependencies'>"
    Then I should see "test 1" within the dependencies of "test 2"
    Then I should see "test 1" within the dependencies of "test 3"
    When I edit the dependency of "test 1" to "'test 2' <'@pc'; 'dependencies'>"
    And I edit the dependency of "test 2" to "'test 3' <'@pc'; 'dependencies'>"
    Then I should see "test 1" within the dependencies of "test 3"
    Then I should see "test 2" within the dependencies of "test 3"

  @selenium @wip
  Scenario: I can remove a dependency by editing the todo
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
    And "test 1" depends on "test 2"
    When I visit the "dependencies" project
    Then I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to ""
    Then I should not see "test 1" within the dependencies of "test 2"
    And I should not see "test 1" in the deferred container

  Scenario: Deleting a predecessor will activate successors
    Given this is a pending scenario

  Scenario: Deleting a successor will update predecessor
    Given this is a pending scenario