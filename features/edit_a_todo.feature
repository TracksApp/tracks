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

  @selenium
  Scenario: I can delete a todo
    Given I have a todo "delete me" in the context "@home"
    When I go to the home page
    Then I should see "delete me"
    When I delete the action "delete me"
    Then I should not see "delete me"

  @selenium
  Scenario: Removing the last todo in context will hide context
    Given I have a todo "delete me" in the context "@home"
    And I have a context called "@pc"
    When I go to the home page
    Then I should see the container for context "@home"
    And I should see "delete me" in the context container for "@home"
    When I mark "delete me" as complete
    Then I should not see the container for context "@home"
    When I mark "delete me" as uncompleted
    Then I should see the container for context "@home"
    When I edit the context of "delete me" to "@pc"
    Then I should not see the container for context "@home"
    When I delete the todo "delete me"
    Then I should not see "delete me"
    And I should not see the container for context "@home"
    And I should not see the container for context "@pc"

  @selenium
  Scenario Outline: Deleting the last todo in container will show empty message # only project, context, tag, not todo
    Given I have a context called "@home"
    And I have a project "my project" that has the following todos
      | context | description   | tags      |
      | @home   | first action  | test, bla |
      | @home   | second action | bla       |
    When I go to the <page>
    Then I should not see "<empty message>"
    And I should see "first action"
    When I delete the todo "first action"
    Then I should not see "<empty message>"
    When I delete the todo "second action"
    Then I should see "<empty message>"

    Scenarios:
      | page                     | empty message                                             |
      | "my project" project     | Currently there are no incomplete actions in this project |
      | context page for "@home" | Currently there are no incomplete actions in this context |
      | tag page for "bla"       | No actions found                                          |

  @selenium
  Scenario Outline: I can mark an active todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page>
    Then I should see "<empty message>"
    When I submit a new action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see "<empty message>"
    When I mark "visible todo" as complete
    And I should see "<empty message>"
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                               | empty message                                             |
      | "visible project" project          | Currently there are no incomplete actions in this project |
      | home page                          | Currently there are no incomplete actions                 |
      | tag page for "starred"             | No actions found                                          |
      | context page for "visible context" | Currently there are no incomplete actions in this context |

  @selenium
  Scenario Outline: I can mark a deferred todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page> 
    Then I should see "<empty message>"
    When I submit a new deferred action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see "<empty message>"
    When I mark "visible todo" as complete
    And I should see "<empty message>"
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                               | empty message                                      |
      | tag page for "starred"             | Currently there are no deferred or pending actions |
      | "visible project" project          | Currently there are no deferred or pending actions |

  @selenium @wip
  Scenario Outline: I can mark a completed todo active and it will update empty messages
    Given I have a completed todo with description "visible todo" to project "visible project" with tags "test" in the context "visible context"
    When I go to the <page>
    Then I should see "<empty message>"
    And I should not see "visible context"
    And I should see "<empty completed message>"
    When I mark the complete todo "visible todo" active
    Then I should see "visible context"
    And I should see "<empty completed message>"
    And I should see "visible todo" in the context container for "visible context"
    And I should not see "<empty message>"

    Scenarios:
      | page                               | empty message                                      |
      | tag page for "starred"             | No actions found                                   |
      | home page                          | No actions found                                   |
      | context page for "visible context" | Currently there are no deferred or pending actions |
      | project page for "visible project" | Currently there are no deferred or pending actions |

  Scenario: I can edit a todo to change its description # do for more pages, see #1094
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
