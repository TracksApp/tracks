Feature: Reviewing projects
  As a Tracks user
  In order to keep the todos and projects up to date
  I want to review my projects

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I see stalled projects and can resolve them
    When I go to the projects page
    And I create a new project with description "stalled_project"
    When I go to the review page
    Then I should see the project "stalled_project" in the list of stalled projects
    When I click on the name "stalled_project"
    Then I should see the project details for the project named "stalled_project"
    When I add a todo for that project
    And go to the review page
    Then the project named "stalled_project" should not be in the list of stalled projects

  Scenario: I see blocked projects and can resolve them
    When I go to the todo page
    And I create a new todo with description "todo_on_hold" with the project "project_on_hold" and a "show from" dated in 2017
    And I go to the review page
    Then I should see the project "project_on_hold" in the list of blocked projects
    When I click on the name "project_on_hold"
    Then I should see the project details for the project named "project_on_hold"
    When I edit the todo titled "todo_on_hold" and delete the "show from" date
    And go to the review page
    Then the project named "project_on_hold" should not be in the list blocked projects

  Scenario: I see dated projects and can review them
    When I go to the projects page
    And I create a new project with description "new_project_is_dated"
    When I go to the review page
    Then I should see the project "new_project_is_dated" in the list of dated projects
    When I click on the name "new_project_is_dated"
    Then I should see the project details for the project named "new_project_is_dated"
    When I edit the project settings
    And click on the button 'Reviewed'
    And go to the review page
    Then the project "new_project_is_dated" should not be in the list of dated projects

