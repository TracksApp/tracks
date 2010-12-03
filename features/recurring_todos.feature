Feature: Manage recurring todos
  In order to manage repeating todos
  As a Tracks user
  I want to view, edit, add, or remove recurrence patterns of repeating todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @selenium
  Scenario: Being able to select daily, weekly, monthly and yearly pattern
    When I go to the repeating todos page
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

  @selenium
  Scenario: I can mark a repeat pattern as starred
    Given this scenario is pending

  @selenium
  Scenario: I can edit a repeat pattern
    Given this scenario is pending

  @selenium
  Scenario: I can delete a repeat pattern
    Given this scenario is pending

  @selenium
  Scenario: I can mark a repeat pattern as done
    Given this scenario is pending
