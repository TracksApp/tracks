Feature: Edit a project
  In order to reach a goal by doing several related todos
  As a Tracks user
  I want to manage these todos in a project

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And there exists a project "manage me" for user "testuser"
    And I have logged in as "testuser" with password "secret"

  Scenario: I can go to the note of a project
    Given I have a project "test" with 2 notes
    When I go to the "test" project
    When I click on the first note icon
    Then I should go to that note page

  @javascript
  Scenario: I can describe the project using markup
    When I go to the "manage me" project
    And I edit the project description to "_successful outcome_: project is *done*"
    Then I should see the italic text "successful outcome" in the project description
    And I should see the bold text "done" in the project description

  @javascript
  Scenario: I can edit the project name in place
    Given I have a project "release tracks 1.8" with 1 todos
    When I go to the "release tracks 1.8" project
    And I edit the project name in place to be "release tracks 2.0"
    Then I should see the project name is "release tracks 2.0"
    When I go to the projects page
    Then I should see that a project named "release tracks 1.8" is not present
    And I should see that a project named "release tracks 2.0" is present

  @javascript
  Scenario: I cannot edit the project name in two places at once
    Given I have a project "release tracks 1.8" with 1 todos
    When I go to the "release tracks 1.8" project
    And I click to edit the project name in place
    Then I should be able to change the project name in place
    When I edit the project settings
    Then I should not be able to change the project name in place

  # Ticket #1041
  @javascript
  Scenario: I can change the name of the project using the Edit Project Settings form
    Given I have a project "bananas" with 1 todos
    When I go to the "bananas" project
    And I edit the project name to "cherries"
    Then the project title should be "cherries"

  @javascript
  Scenario: I can change the name of the project and it should update the new todo form
    Given I have a project "bananas" with 1 todos
    When I go to the "bananas" project
    And I edit the project name to "cherries"
    Then the project title should be "cherries"
    And the project field of the new todo form should contain "cherries"

  # Ticket #1789
  @javascript
  Scenario: I can change the name of the project and it should still allow me to add new actions
    Given I have a project "bananas"
    When I go to the "bananas" project
    And I edit the project name to "cherries"
    And I edit the default context to "@pc"
    And I submit a new action with description "a new next action"
    Then I should see the todo "a new next action"

  @javascript
  Scenario: I can change the default context of the project and it should update the new todo form
    Given I have a project "bananas" with 1 todos
    When I go to the "bananas" project
    And I edit the default context to "@pc"
    Then the default context of the new todo form should be "@pc"
    # the default context should be prefilled ater submitting a new todo
    When I submit a new action with description "test"
    Then the default context of the new todo form should be "@pc"

  # Ticket #1042
  @javascript
  Scenario: I cannot change the name of a project in the project view to the name of another existing project
    Given I have a project "test" with 1 todos
    When I go to the projects page
    Then the badge should show 2   # "manage me" and "test"
    When I go to the "manage me" project
    And I try to edit the project name to "test"
    Then I should see "Name already exists"

  # Ticket #1042
  @javascript
  Scenario: I cannot change the name of a project in the project list view to the name of another existing project
    Given I have a project "test" with 1 todos
    When I go to the projects page
    Then the badge should show 2   # "manage me" and "test"
    When I try to edit the project name of "manage me" to "test"
    Then I should see "Name already exists"

  @javascript
  Scenario: I can add a note to the project
    Given I have a project called "test"
    When I go to the "test" project
    And I add a note "hello I'm testing" to the project
    Then I should see one note in the project

  @javascript
  Scenario: Cancelling adding a note to the project will remove form
    Given I have a project called "test"
    When I go to the "test" project
    And I cancel adding a note to the project
    Then the form for adding a note should not be visible

  @javascript
  Scenario: Long notes in a project are shown cut off
    Given I have a project called "test"
    When I go to the "test" project
    And I add a note "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890TOO LONG" to the project
    Then I should not see the note "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890TOO LONG"
    And I should see the note "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456"

  @javascript
  Scenario: Cancelling editing a project will restore project settings
    Given I have a project called "test"
    When I go to the "test" project
    Then I should see the default project settings
    When I open the project edit form
    Then I should not see the default project settings
    When I cancel the project edit form
    Then I should see the default project settings

  @javascript
  Scenario: Moving the todo to the tickler will move todo to tickler container and update empty messages
    Given I have a project "test" with 1 todos
    When I go to the "test" project
    Then I should see "todo 1" in the context container for "Context A"
    And I should see empty message for deferred todos of project
    And I should see empty message for completed todos of project
    When I defer "todo 1" for 1 day
    Then I should see "todo 1" in the deferred container
    And I should not see empty message for deferred todos of project
    And I should see empty message for completed todos of project
    And I should see empty message for todos of project

  @javascript
  Scenario: Moving the todo out of the tickler will move todo to active container and update empty messages
    Given I have a project "test" with 1 deferred todos
    When I go to the "test" project
    Then I should see "deferred todo 1" in the deferred container
    And I should see empty message for todos of project
    And I should not see empty message for deferred todos of project
    When I clear the show from date of "deferred todo 1"
    Then I should see "deferred todo 1" in the action container
    And I should see empty message for deferred todos of project
    And I should not see empty message for todos of project

  @javascript
  Scenario: Making all todos inactive will show empty message
    Given I have a project "test" with 1 todos
    When I go to the "test" project
    And I mark "todo 1" as complete
    Then I should see empty message for todos of project

  @javascript
  Scenario: Making all deferred todos inactive will show empty message
    Given I have a project "test" with 1 deferred todos
    When I go to the "test" project
    And I mark "deferred todo 1" as complete
    Then I should see empty message for todos of project
    And I should see empty message for deferred todos of project

  # Ticket #1043
  @javascript
  Scenario: I can move a todo out of the current project
    Given I have a project "foo" with 2 todos
    And I have a project called "bar"
    When I go to the "foo" project
    And I change the project_name field of "todo 1" to "bar"
    Then I should not see the todo "todo 1"
    And I should see the todo "todo 2"
