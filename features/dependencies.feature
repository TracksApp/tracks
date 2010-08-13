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

  @selenium, @wip
  Scenario: Adding dependency with comma to todo   # for #975
  Given I have a context called "@pc"
  And I have a project "dependencies" that has the following todos
    | description | context |
    | test,1, 2,3 | @pc     |
    | test me     | @pc     |
  When I visit the "dependencies" project
  And I drag "test me" to "test,1, 2,3"
  Then the dependencies of "test me" should include "test,1, 2,3"
  When I edit the dependency of "test me" to '"test,1, 2,3" <"@pc"; "dependencies">,"test,1, 2,3" <"@pc"; "dependencies">'
  Then there should not be an error 