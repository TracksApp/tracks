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
    Then I should see "<i>successfull outcome<i>"
    And I should see " <b>done</b>"