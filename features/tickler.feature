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

  Scenario: Editing the description of a todo updated the todo
    Given this scenario is pending

  Scenario: Editing the context of a todo moves it to the new context
    Given this scenario is pending

  Scenario: Removing the show from date from a todo removes it from the tickler
    Given this scenario is pending
