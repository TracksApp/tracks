Feature: Manage recurring todos
  In order to manage recurring todos
  As a Tracks user
  I want to view, edit, add, or remove recurrence patterns of recurring todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "test context"
    And I have a recurrence pattern called "run tests"

  @javascript
  Scenario: Being able to select daily, weekly, monthly and yearly pattern
    When I go to the recurring todos page
    And I follow "Add a new recurring action"
    Then I should see the form for "Daily" recurrence pattern
    When I select "Weekly" recurrence pattern
    Then I should see the form for "Weekly" recurrence pattern
    When I select "Monthly" recurrence pattern
    Then I should see the form for "Monthly" recurrence pattern
    When I select "Yearly" recurrence pattern
    Then I should see the form for "Yearly" recurrence pattern
    When I select "Daily" recurrence pattern
    Then I should see the form for "Daily" recurrence pattern

  @javascript
  Scenario: I can mark a recurrence pattern as starred
    When I go to the recurring todos page
    And I star the pattern "run tests"
    Then the pattern "run tests" should be starred

  @javascript
  Scenario: I can edit a recurrence pattern
    When I go to the recurring todos page
    And I edit the name of the pattern "run tests" to "report test results"
    Then the pattern "report test results" should be in the state list "active"
    And I should not see "run tests"

  @javascript
  Scenario: I can delete a recurrence pattern
    When I go to the recurring todos page
    And I delete the pattern "run tests"
    And I should not see "run tests"

  @javascript
  Scenario: I can mark a recurrence pattern as done
    When I go to the recurring todos page
    Then the pattern "run tests" should be in the state list "active"
    And the state list "completed" should be empty
    When I mark the pattern "run tests" as complete
    Then the pattern "run tests" should be in the state list "completed"
    And the state list "active" should be empty

  @javascript
  Scenario: I can reactivate a recurrence pattern
    Given I have a completed recurrence pattern "I'm done"
    When I go to the recurring todos page
    Then the pattern "I'm done" should be in the state list "completed"
    When I mark the pattern "I'm done" as active
    Then the pattern "I'm done" should be in the state list "active"
    And the state list "completed" should be empty

  @javascript
  Scenario: Following the recurring todo link of a todo takes me to the recurring todos page
    When I go to the home page
    Then I should see the todo "run tests"
    When I follow the recurring todo link of "run tests"
    Then I should be on the recurring todos page

  @javascript
  Scenario: Deleting a recurring todo with ending pattern will show message
    When I go to the recurring todos page
    And I mark the pattern "run tests" as complete
    And I go to the home page
    Then I should see "run tests"
    When I delete the action "run tests"
    Then I should see "There is no next action after the recurring action you just deleted. The recurrence is completed"

  @javascript
  Scenario: Deleting a recurring todo with active pattern will show new todo
    When I go to the home page
    Then I should see "run tests"
    When I delete the action "run tests"
    Then I should see "Action was deleted. Because this action is recurring, a new action was added"
    And I should see "run tests" in the context container for "test context"