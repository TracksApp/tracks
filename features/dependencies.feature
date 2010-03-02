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
  Given I have a project "dependencies" with 3 todos
  And "Todo 2" depends on "Todo 1"
  When I visit the "dependencies" project
  And I drag "Todo 3" to "Todo 2"
  Then the dependencies of "Todo 2" should include "Todo 1"
  And the dependencies of "Todo 3" should include "Todo 2"
  When I expand the dependencies of "Todo 1"
  Then I should see "Todo 2" within the dependencies of "Todo 1"
  And I should see "Todo 3" within the dependencies of "Todo 1"
  When I expand the dependencies of "Todo 2"
  Then I should see "Todo 3" within the dependencies of "Todo 2"