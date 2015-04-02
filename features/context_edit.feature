Feature: Edit a context
  In order to work on todos in a context
  As a Tracks user
  I want to manage todos in a context

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@pc"
    And I have a project called "test project"
    And I have 2 todos in project "test project" in context "@pc" with tags "starred" prefixed by "test_project "

  @javascript
  Scenario: In place edit of context name
    When I go to the context page for "@pc"
    And I edit the context name in place to be "OutAndAbout"
    Then I should see the context name is "OutAndAbout"
    When I go to the contexts page
    Then I should see that a context named "Errands" is not present
    And I should see that a context named "OutAndAbout" is present

  # Ticket #1796
  @javascript
  Scenario: I can change the name of the context and it should update the new todo form
    When I go to the context page for "@pc"
    And I edit the context name in place to be "OutAndAbout"
    Then the context field of the new todo form should contain "OutAndAbout"

  # Ticket #1789
  @javascript
  Scenario: I can change the name of the context and it should still allow me to add new actions
    When I go to the context page for "@pc"
    And I edit the context name in place to be "OutAndAbout"
    And I submit a new action with description "a new next action"
    Then I should see the todo "a new next action"

  @javascript
  Scenario: Editing the context of a todo will remove the todo
    When I go to the the context page for "@pc"
    Then the badge should show 2
    When I edit the context of "test_project todo 1" to "@laptop"
    Then I should not see the todo "todo 1"
    And the badge should show 1

  @javascript 
  Scenario: Editing the description of a a todo will update that todo
    When I go to the the context page for "@pc"
    And I edit the description of "test_project todo 1" to "changed"
    Then I should not see the todo "test_project todo 1"
    And I should see "changed"

  @javascript 
  Scenario: Editing the context of the last todo will remove the todo and show empty message
    When I go to the the context page for "@pc"
    And I edit the context of "test_project todo 1" to "@laptop"
    Then I should not see the todo "test_project todo 1"
    And the badge should show 1
    When I edit the context of "test_project todo 2" to "@laptop"
    Then I should not see the todo "test_project todo 2"
    And the badge should show 0
    And I should see empty message for todos of context

  @javascript
  Scenario: Adding a todo to a hidden project will not show the todo
    Given I have a hidden project called "hidden project"
    When I go to the the context page for "@pc"
    And I edit the project of "test_project todo 1" to "hidden project"
    Then I should not see the todo "test_project todo 1"
    When I submit a new action with description "todo X" to project "hidden project" in the context "@pc"
    Then I should not see the todo "todo X"
    When I go to the "hidden project" project
    Then I should see the todo "test_project todo 1"
    And I should see the todo "todo X"
    And the badge should show 2

  @javascript
  Scenario: Adding a todo to a hidden context will show that todo
    Given I have a hidden context called "@personal"
    When I go to the the context page for "@pc"
    And I edit the context of "test_project todo 1" to "@personal"
    Then I should not see the todo "test_project todo 1"
    When I go to the context page for "@personal"
    Then I should see the todo "test_project todo 1"
    When I submit a new action with description "todo X" to project "test project" in the context "@personal"
    Then I should see the todo "todo X"
    
  @javascript
  Scenario: Moving the todo to the tickler will move todo to tickler container and update empty messages
    Given I have a context "test" with 1 todos
    When I go to the "test" context
    Then I should see "todo 1" in the action container
    And I should see empty message for deferred todos of context
    And I should see empty message for completed todos of context
    When I defer "todo 1" for 1 day
    Then I should see "todo 1" in the deferred container
    And I should not see empty message for deferred todos of context
    And I should see empty message for completed todos of context
    And I should see empty message for todos of context
    
  @javascript
  Scenario: Moving the todo out of the tickler will move todo to active container and update empty messages
    Given I have a context "test" with 1 deferred todos
    When I go to the "test" context
    Then I should see "deferred todo 1" in the deferred container
    And I should see empty message for todos of context
    And I should not see empty message for deferred todos of context
    When I clear the show from date of "deferred todo 1"
    Then I should see "deferred todo 1" in the action container
    And I should see empty message for deferred todos of context
    And I should not see empty message for todos of context

  @javascript 
  Scenario: Making all deferred todos inactive will show empty message
    Given I have a context "test" with 1 deferred todos
    When I go to the "test" context
    And I mark "deferred todo 1" as complete
    Then I should see empty message for todos of context
    And I should see empty message for deferred todos of context
