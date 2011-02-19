Feature: Manage deferred todos
  In order to hide todos that require attention in the future and not now
  As a Tracks user
  I want to defer these and manage them in a tickler

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And there exists a project "manage me" for user "testuser"
    And I have logged in as "testuser" with password "secret"

  @selenium @wip
  Scenario: I can add a deferred todo and it will show in the tickler
    # also adding the first deferred todo will hide the empty message
    When I go to the tickler
    Then I should see the empty tickler message
    When I submit a deferred new action with description "a new next action"
    Then I should see "a new next action"
    And I should not see the empty tickler message

  Scenario: Editing the description of a todo updated the todo
    Given this is a pending scenario

  Scenario: Editing the context of a todo moves it to the new context
    Given this is a pending scenario

  Scenario: Removing the show from date from a todo removes it from the tickler
    Given this is a pending scenario

  Scenario: Opening the tickler page shows me all deferred todos
    Given I have a deferred todo "not yet now"
    And I have a todo "now is a good time"
    When I go to the tickler page
    Then I should see "not yet now"
    And I should not see "now is a good time"
