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
