Feature: dependencies

  As a Tracks user
  In order to keep track of complex todos
  I want to assign and manage todo dependencies

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @selenium
  Scenario: Adding dependency to dependency
  Given I have 3 todos
  And "todo 2" depends on "todo 1"
  When I go to the home page
  And I drag "todo 3" to "todo 1"
  Then the dependencies of "todo 1" should include "todo 2"
  And the dependencies of "todo 1" should include "todo 3"