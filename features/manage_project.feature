Feature: Manage a project

  In order to reach a goal by doing several related todos
  As a Tracks user
  I want to manage these todos in a project

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And there exists a project "manage me" for user "testuser"

  @selenium
  Scenario: I can describe the project using markup
    When I visit the "manage me" project
    And I edit the project description to "_successfull outcome_: project is *done*"
    Then I should see the italic text "successfull outcome" in the project description
    And I should see the bold text "done" in the project description

  # Ticket #1043
  @selenium
  Scenario: I can move a todo out of the current project
    Given I have a project "foo" with 2 todos
    When I visit the "foo" project
    And I change the project_name field of "Todo 1" to "bar"
    Then I should not see the todo "Todo 1"
    And I should see the todo "Todo 2"

  # Ticket #1041
  @selenium
  Scenario: I can change the name of the project using the Edit Project Settings form
    Given I have a project "bananas" with 1 todos
    When I visit the "bananas" project
    And I edit the project name to "cherries"
    Then the project title should be "cherries"
