Feature: Edit a next action from every page
  In order to manage a next action
  As a Tracks user
  I want to to be able to change the next action from every page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I can toggle the star of a todo
    Given this is a pending scenario

  Scenario: I can delete a todo
    Given this is a pending scenario

  Scenario: Removing the last todo in context will hide context # delete, edit
    Given this is a pending scenario

  Scenario: Deleting the last todo in container will show empty message # only project, context, tag, not todo
    Given this is a pending scenario

  Scenario: I can mark a todo complete
    Given this is a pending scenario

  Scenario: I can mark a completed todo active
    Given this is a pending scenario

  Scenario: I can edit a todo to change its description
    Given this is a pending scenario

  Scenario: I can edit a todo to move it to another context
    Given this is a pending scenario

  Scenario: I can edit a todo to move it to another project
    Given this is a pending scenario

  Scenario: I can edit a todo to move it to the tickler
    Given this is a pending scenario

  Scenario: I can defer a todo
    Given this is a pending scenario

  Scenario: I can make a project from a todo
    Given this is a pending scenario

  Scenario: I can show the notes of a todo
    Given this is a pending scenario

  Scenario: I can tag a todo
    Given this is a pending scenario

  Scenario: Clicking a tag of a todo will go to that tag page
    Given this is a pending scenario

  Scenario: I can edit the tags of a todo
    Given this is a pending scenario

  Scenario: Editing the context of a todo to a new context will show new context
    Given this is a pending scenario # for home and tickler and tag

  Scenario: Making an error when editing a todo will show error message
    Given this is a pending scenario
