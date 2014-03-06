Feature: Show all due actions in a calendar view
  As a Tracks user
  In order to keep overview of my due todos
  I want to manage due todos in a calendar view

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@calendar"

  @javascript
  Scenario: Setting due date of a todo will show it in the calendar
    When I submit a new action with description "something new" in the context "@calendar"
    And I go to the calendar page
    Then the badge should show 0
    And I should not see the todo "something new"
    When I go to the home page
    Then I should see the todo "something new"
    When I edit the due date of "something new" to tomorrow
    And I go to the calendar page
    Then I should see the todo "something new"
    And the badge should show 1

  @javascript
  Scenario: Clearing the due date of a todo will remove it from the calendar
    When I go to the home page
    And I submit a new action with description "something new" in the context "@calendar"
    And I edit the due date of "something new" to tomorrow
    And I go to the calendar page
    Then I should see the todo "something new"
    When I clear the due date of "something new"
    Then I should not see the todo "something new"

  @javascript
  Scenario: Marking a todo complete will remove it from the calendar
    Given I have a todo "something new" in the context "@calendar" which is due tomorrow
    When I go to the calendar page
    Then I should see the todo "something new"
    When I clear the due date of "something new"
    Then I should not see the todo "something new"

  @javascript 
  Scenario: Deleting a todo will remove it from the calendar
    Given I have a todo "something new" in the context "@calendar" which is due tomorrow
    When I go to the calendar page
    Then I should see the todo "something new"
    When I delete the action "something new"
    Then I should not see the todo "something new"

  @javascript
  Scenario: Changing due date of a todo will move it in the calendar
    Given I have a todo "something new" in the context "@calendar" which is due tomorrow
    When I go to the calendar page
    Then I should see the todo "something new"
    When I edit the due date of "something new" to next month
    Then I should see "something new" in the due next month container
