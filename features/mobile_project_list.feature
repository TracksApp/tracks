Feature: View the list of projects from mobile
  In order to be able to see all project from the mobile interface
  As a Tracks user
  I want to to be able to see a list of project

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I am working on the mobile interface
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@mobile"
    And I have a project "test project" that has the following todos
      | context | description |
      | @mobile | test action |

  Scenario: I can go to a project from the list of project in mobile view
    Given I am on the projects page
    Then I should see "test project"
    When I follow "test project"
    Then the badge should show 1
    And I should see "test action"
