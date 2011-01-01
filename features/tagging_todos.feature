Feature: Tagging todos
  In order to organise my todos in various lists
  As a Tracks user
  I want to to be able to add or edit one or more tags to todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I can edit a todo to add tags to that todo
    Given this is a pending scenario

  Scenario: I can add a new todo with tags
    Given this is a pending scenario

  Scenario: I can show all todos tagged with a specific tag
    Given this is a pending scenario

  Scenario: I can remove a tag from a todo from the tag view and the tag will be removed
    Given this is a pending scenario

  Scenario: I can add a new todo from tag view with that tag and it will be added to the page
    Given this is a pending scenario

  Scenario: I can add a new todo from tag view with a different tag and it will not be added to the page
    Given this is a pending scenario

  Scenario: I can change the context of a tagged todo in tag view and it will move the tag on the page
    Given this is a pending scenario

  Scenario: I can defer a tagged todo in tag view and it will move the todo on the page to the deferred container
    Given this is a pending scenario

  Scenario: I can move a tagged todo in tag view to a hidden project and it will move the todo on the page to the hidden container
    Given this is a pending scenario

Scenario: I can move a tagged todo in tag view to a hidden context and it will move the todo on the page to the hidden container
    Given this is a pending scenario
