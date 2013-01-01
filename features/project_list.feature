Feature: Manage the list of projects
  In order to keep track and manage of all my projects
  As a Tracks user
  I want to manage my list of projects

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And there exists a project "manage me" for user "testuser"
    And there exists a project "upgrade jquery" for user "testuser"
    And there exists a project "a project name starting with a" for user "testuser"
    And I have logged in as "testuser" with password "secret"

  Scenario: The list of projects contain all projects
    When I go to the projects page
    Then I should see "manage me"
    And I should see "upgrade jquery"
    And I should see "a project name starting with a"
    And the badge should show 3

  Scenario: Clicking on a project takes me to the project page
    When I go to the projects page
    And I follow "manage me"
    Then I should be on the "manage me" project page

  @javascript
  Scenario: Editing a project name will update the list
    When I go to the projects page
    And I edit the project name of "manage me" to "manage him"
    Then I should see "manage him"

  @javascript
  Scenario: Deleting a project will remove it from the list
    When I go to the projects page
    And I delete project "manage me"
    Then I should see that a project named "manage me" is not present
    And the badge should show 2
    And the project list badge for "active" projects should show 2

  @javascript
  Scenario: Deleting a project after a edit will remove it from the list
    # make sure the js is enabled after an edit and another edit
    When I go to the projects page
    And I edit the project name of "manage me" to "manage him"
    Then I should see a project named "manage him"
    When I edit the project name of "manage him" to "manage her"
    Then I should see a project named "manage her"
    When I delete project "manage her"
    Then I should not see a project named "manage her"
    And the badge should show 2
    And the project list badge for "active" projects should show 2

  @javascript
  Scenario: Changing project state will move project to other state list
    When I go to the projects page
    Then the project "manage me" should be in state list "active"
    And the project list badge for "active" projects should show 3
    When I edit the project state of "manage me" to "hidden"
    Then the project "manage me" should not be in state list "active"
    And the project "manage me" should be in state list "hidden"
    And the project list badge for "active" projects should show 2
    And the project list badge for "hidden" projects should show 1

  @javascript
  Scenario: Dragging a project to change list order of projects
    When I go to the projects page
    Then the project "manage me" should be above the project "upgrade jquery"
    When I drag the project "manage me" below "upgrade jquery"
    Then the project "upgrade jquery" should be above the project "manage me"

  @javascript
  Scenario: Hiding and unhiding the new project form
    When I go to the projects page
    Then the new project form should be visible
    When I follow "Hide form"
    Then the new project form should not be visible
    When I follow "Create a new project"
    Then the new project form should be visible

  @javascript
  Scenario: Adding a new project
    When I go to the projects page
    And I submit a new project with name "finish cucumber tests"
    Then I should see "finish cucumber tests"
    And the badge should show 4
    And the project list badge for "active" projects should show 4

  @javascript
  Scenario: Adding a new project and take me to the project page
    When I go to the projects page
    And I submit a new project with name "finish cucumber tests" and select take me to the project
    Then I should be on the "finish cucumber tests" project page

  @javascript
  Scenario: Sorting the project alphabetically
    When I go to the projects page
    Then the project "manage me" should be above the project "a project name starting with a"
    When I sort the active list alphabetically
    Then the project "a project name starting with a" should be above the project "manage me"

  @javascript
  Scenario: Sorting the project by number of task
    Given I have a project "test" with 2 todos
    And I have a project "very busy" with 10 todos
    When I go to the projects page
    Then the project "test" should be above the project "very busy"
    When I sort the active list by number of tasks
    Then the project "very busy" should be above the project "test"

  @javascript
  Scenario: Can add a project with comma in the name
    When I go to the projects page
    And I submit a new project with name "foo,bar"
    Then I should see "foo,bar"
    And the badge should show 4
    And the project list badge for "active" projects should show 4

  @javascript
  Scenario: Listing projects with only active actions
    Given I have a project "do it now" with 2 active todos
    When I go to the projects page
    Then the project "do it now" should have 2 actions listed

  @javascript
  Scenario: Listing projects with both active and deferred actions
    Given I have a project "now and later" with 2 active actions and 2 deferred actions
    When I go to the projects page
    Then the project "now and later" should have 2 actions listed

  @javascript
  Scenario: Listing projects with only deferred actions
    Given I have a project "only later" with 3 deferred actions
    When I go to the projects page
    Then the project "only later" should have 3 deferred actions listed

  @javascript
  Scenario: Listing projects with no actions
    Given I have a project "all done" with 0 active actions and 0 deferred actions
    When I go to the projects page
    Then the project "all done" should have 0 actions listed
