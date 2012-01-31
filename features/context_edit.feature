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
    And I have 2 todos in project "test project" in context "@pc" with tags "starred"

  @javascript
  Scenario: In place edit of context name
    Given I have a context called "Errands"
    When I go to the context page for "Errands"
    And I edit the context name in place to be "OutAndAbout"
    Then I should see the context name is "OutAndAbout"
    When I go to the contexts page
    Then he should see that a context named "Errands" is not present
    And he should see that a context named "OutAndAbout" is present

  @javascript
  Scenario: Editing the context of a todo will remove the todo
    When I go to the the context page for "@pc"
    Then the badge should show 2
    When I edit the context of "todo 1" to "@laptop"
    Then I should not see "todo 1"
    And the badge should show 1

  @javascript
  Scenario: Editing the description of a a todo will update that todo
    When I go to the the context page for "@pc"
    And I edit the description of "todo 1" to "changed"
    Then I should not see "todo 1"
    And I should see "changed"

  @javascript
  Scenario: Editing the context of the last todo will remove the todo and show empty message
    When I go to the the context page for "@pc"
    And I edit the context of "todo 1" to "@laptop"
    Then I should not see "todo 1"
    And the badge should show 1
    When I edit the context of "todo 2" to "@laptop"
    Then I should not see "todo 2"
    And the badge should show 0
    And I should see "Currently there are no incomplete actions in this context"

  @javascript
  Scenario: Adding a todo to a hidden project will not show the todo
    Given I have a hidden project called "hidden project"
    When I go to the the context page for "@pc"
    And I edit the project of "todo 1" to "hidden project"
    Then I should not see "todo 1"
    When I submit a new action with description "todo X" to project "hidden project" in the context "@pc"
    Then I should not see "todo X"
    When I go to the "hidden project" project
    Then I should see "todo 1"
    And I should see "todo X"
    And the badge should show 2

  @javascript
  Scenario: Adding a todo to a hidden context will show that todo
    Given I have a hidden context called "@personal"
    When I go to the the context page for "@pc"
    And I edit the context of "todo 1" to "@personal"
    Then I should not see "todo 1"
    When I go to the context page for "@personal"
    Then I should see "todo 1"
    When I submit a new action with description "todo X" to project "test project" in the context "@personal"
    Then I should see "todo X"
