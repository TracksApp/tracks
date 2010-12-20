Feature: dependencies
  As a Tracks user
  In order to keep overview of my due todos
  I want to manage due todos in a calendar view

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: Setting due date of a todo will show it in the calendar
    Given this is a pending scenario

  Scenario: Clearing the due date of a todo will remove it from the calendar
    Given this is a pending scenario

  Scenario: Changing due date of a todo will move it in the calendar
    Given this is a pending scenario
