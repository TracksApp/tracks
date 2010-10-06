Feature: Manage the list of projects

  In order to keep tracks and manage of all my projects
  As a Tracks user
  I want to manage the list of projects

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And there exists a project "manage me" for user "testuser"
    And there exists a project "upgrade jquery" for user "testuser"
    And there exists a project "a project name starting with a" for user "testuser"

  Scenario: The list of project contain all projects
    When I go to the projects page
    Then I should see "manage me"
    And I should see "upgrade jquery"
    And the badge should show 2

  Scenario: Clicking on a project takes me to the project page
    When I go to the projects page
    And I follow "manage me"
    Then I should be on the "manage me" project page

  @selenium
  Scenario: Editing a project name will update the list
    When I go to the projects page
    And I edit the project name for "manage me" to "manage him"
    Then I should see "manage him"

  Scenario: Dragging a project to change list order of projects
  Scenario: Deleting a project will remove it from the list
  Scenario: Changing project state will move project to other state list
  Scenario: Adding a new project
  Scenario: Adding a new project and take me to the project page
  Scenario: Hiding and unhiding the new project form
  Scenario: Sorting the project alphabetically
  Scenario: Sorting the project by number of task