Feature: Show all due actions in a calendar view
  As a Tracks user
  In order to keep overview of my due todos
  I want to manage due todos in a calendar view

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I can search for todos by partial description
    Given I have the following todos:
      | description     | context |
      | tester of stuff | @home   |
      | testing search  | @work   |
      | unrelated stuff | @home   |
    When I go to the search page
    And I search for "test"
    Then I should see "tester"
    And I should see "testing search"
    When I go to the search page
    And I search for "stuff"
    Then I should see "tester of stuff"
    And I should see "unrelated stuff"

  @javascript
  Scenario: I can edit found todos
      Given I have the following todos:
      | description     | context |
      | tester of stuff | @home   |
      | testing search  | @work   |
    When I go to the search page
    And I search for "test"
    Then I should see the todo "tester of stuff"
    When I star the action "tester of stuff"
    Then I should see a starred "tester of stuff"
    When I edit the description of "tester of stuff" to "test 1-2-3"
    Then I should not see the todo "tester of stuff"
    And I should see the todo "test 1-2-3"
    When I go to the search page
    And I search for "test"
    Then I should not see the todo "tester of stuff"
    And I should see the todo "test 1-2-3"

  @javascript 
  Scenario: I can delete found todos
      Given I have the following todos:
      | description     | context |
      | tester of stuff | @home   |
      | testing search  | @work   |
    When I go to the search page
    And I search for "test"
    Then I should see "tester of stuff"
    When I delete the action "tester of stuff"
    Then I should not see "tester of stuff"
    When I go to the search page
    And I search for "test"
    Then I should not see "tester of stuff"

  @javascript
  Scenario: I can mark found todos complete and uncomplete
      Given I have the following todos:
      | description     | context |
      | tester of stuff | @home   |
      | testing search  | @work   |
    When I go to the search page
    And I search for "test"
    Then I should see an active todo "tester of stuff"
    When I mark "tester of stuff" as complete
    Then I should see a completed todo "tester of stuff"
    # the completed todo should show up on the next search too
    When I go to the search page
    And I search for "test"
    Then I should see a completed todo "tester of stuff"
    When I mark "tester of stuff" as uncompleted
    Then I should see an active todo "tester of stuff"
    # the active todo should show up on the next search too
    When I go to the search page
    And I search for "test"
    Then I should see an active todo "tester of stuff"
