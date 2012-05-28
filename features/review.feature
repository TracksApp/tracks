Feature: Reviewing projects
  In order to keep the todos and projects up to date
  As a Tracks user
  I want to review my projects

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I see stalled projects
    Given I have no projects
    Given I have a project "stalled_project" with 0 todos
    When I go to the review page
    Then I see the project "stalled_project" in the "stalled" list

  Scenario: I see blocked projects
    Given I have no projects
    Given I have a project "blocked_project" with 1 deferred todos
    When I go to the review page
    Then I see the project "blocked_project" in the "blocked" list

  Scenario: I see dated projects
    Given I have no projects
    Given I have an outdated project "dated_project" with 1 todos
    When I go to the review page
    Then I see the project "dated_project" in the "review" list

  Scenario: The review list of projects contains all projects
    Given I have no projects
    Given I have a project "stalled_project" with 0 todos
    Given I have a project "blocked_project" with 1 deferred todos
    Given I have an outdated project "dated_project" with 1 todos
    When I go to the review page
    And the badge should show 5 ## note that stalled and blocked projects are also up-to-date listed

  @javascript
  Scenario: I can mark a project as reviewed from the projects list page
    Given I have a project called "review me"
    When I go to the projects page
    Then I should see "review me"
    When I edit project "review me" and mark the project as reviewed
    Then I should be on the projects page
    And I should see "review me"
    
  @javascript
  Scenario: I can mark a project as reviewed from the project page
    Given I have a project called "review me"
    When I go to the "review me" project
    When I edit project settings and mark the project as reviewed
    Then I should be on the "review me" project

  @javascript
  Scenario: I can mark a project as reviewed from the review page
    Given I have an outdated project "review me" with 1 todos
    When I go to the review page
    Then I should see "review me"
    When I edit project "review me" and mark the project as reviewed
    Then I should be on the review page