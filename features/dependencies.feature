Feature: dependencies
  As a Tracks user
  In order to keep track of complex todos that are dependent on each other
  I want to assign and manage todo dependencies

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @javascript
  Scenario: Adding dependency to dependency by drag and drop
    Given I have a project "dependencies" with 3 todos
    And "todo 2" depends on "todo 1"
    When I go to the "dependencies" project
    And I drag "todo 3" to "todo 2"
    Then the successors of "todo 1" should include "todo 2"
    And the successors of "todo 2" should include "todo 3"
    When I expand the dependencies of "todo 1"
    Then I should see "todo 2" within the dependencies of "todo 1"
    And I should see "todo 3" within the dependencies of "todo 1"
    When I expand the dependencies of "todo 2"
    Then I should see "todo 3" within the dependencies of "todo 2"

  @javascript 
  Scenario: I can edit a todo to add the todo as a dependency to another
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    When I go to the "dependencies" project
    When I edit the dependency of "test 1" to add "test 2" as predecessor
    Then I should see "test 1" within the dependencies of "test 2"
    And I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to add "test 3" as predecessor
    Then I should see "test 1" within the dependencies of "test 2"
    Then I should see "test 1" within the dependencies of "test 3"
    When I edit the dependency of "test 1" to remove "test 3" as predecessor
    And I edit the dependency of "test 2" to add "test 3" as predecessor
    Then I should see "test 1" within the dependencies of "test 3"
    Then I should see "test 2" within the dependencies of "test 3"

  @javascript
  Scenario: I can remove a dependency by editing the todo
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
    And "test 1" depends on "test 2"
    When I go to the "dependencies" project
    Then I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to remove "test 2" as predecessor
    Then I should not see "test 1" within the dependencies of "test 2"
    And I should not see "test 1" in the deferred container

  @javascript 
  Scenario: Completing a predecessor will activate successors
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    And "test 2" depends on "test 1"
    When I go to the "dependencies" project
    Then I should see "test 2" in the deferred container
    And I should see "test 1" in the context container for "@pc"
    When I mark "test 1" as complete
    Then I should see "test 1" in the completed container
    And I should see "test 2" in the context container for "@pc"
    And I should not see "test 2" in the deferred container
    And I should see empty message for deferred todos of project

  @javascript
  Scenario: Deleting a predecessor will activate successors
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    And "test 2" depends on "test 1"
    When I go to the "dependencies" project
    Then I should see "test 2" in the deferred container
    And I should see "test 1" in the context container for "@pc"
    When I delete the action "test 1"
    Then I should see "test 2" in the context container for "@pc"
    And I should not see "test 2" in the deferred container
    And I should see empty message for deferred todos of project

  @javascript
  Scenario: Deleting a successor will update predecessor
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    And "test 2" depends on "test 1"
    And "test 3" depends on "test 1"
    When I go to the "dependencies" project
    And I expand the dependencies of "test 1"
    Then I should see "test 2" within the dependencies of "test 1"
    And I should see "test 3" within the dependencies of "test 1"
    When I delete the action "test 2"
    And I expand the dependencies of "test 1"
    Then I should see "test 3" within the dependencies of "test 1"
    And I should not see "test 2"

  @javascript 
  Scenario: Dragging an action to a completed action will not add it as a dependency
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context | completed |
      | test 1      | @pc     | no        |
      | test 2      | @pc     | no        |
      | test 3      | @pc     | yes       |
    When I go to the "dependencies" project
    And I drag "test 1" to "test 3"
    Then I should see an error flash message saying "Cannot add this action as a dependency to a completed action!"
    And I should see "test 1" in the context container for "@pc"

  @javascript 
  Scenario Outline: Marking a successor as complete will update predecessor
    Given I have a context called "@pc"
    And I have selected the view for group by <grouping>
    And I have a project "dependencies" that has the following todos
      | description | context | completed | tags |
      | test 1      | @pc     | no        | bla  |
      | test 2      | @pc     | no        | bla  |
      | test 3      | @pc     | yes       | bla  |
    When I go to the <page>
    And I drag "test 1" to "test 2"
    When I expand the dependencies of "test 2"
    Then I should see "test 1" within the dependencies of "test 2"
    And I should see "test 1" in the deferred container
    When I mark "test 1" as complete
    Then I should see that "test 2" does not have dependencies
    And I should see "test 1" in the completed container

    Scenarios:
    | page                    | grouping |
    | "dependencies" project  | project  |
    | tag page for "bla"      | context  |
    | tag page for "bla"      | project  |

  @javascript
  Scenario Outline: Marking a successor as active will update predecessor
    Given I have a context called "@pc"
    And I have selected the view for group by <grouping>
    And I have a project "dependencies" that has the following todos
      | description | context | completed | tags |
      | test 1      | @pc     | no        | bla  |
      | test 2      | @pc     | no        | bla  |
      | test 3      | @pc     | yes       | bla  |
    When I go to the <page>
    And I drag "test 1" to "test 2"
    Then I should see "test 1" in the deferred container
    When I mark "test 1" as complete
    And I should see "test 1" in the completed container
    And I should see that "test 2" does not have dependencies
    When I mark the completed todo "test 1" active
    Then I should not see "test 1" in the completed container
    And I should see "test 1" in the deferred container
    And I should see "test 1" within the dependencies of "test 2"

    Scenarios:
    | page                    | grouping |
    | "dependencies" project  | project  |
    | "dependencies" project  | context  |
    | tag page for "bla"      | context  |
    | tag page for "bla"      | project  |