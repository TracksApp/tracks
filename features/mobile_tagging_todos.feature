Feature: Show the actions that are tagged on the mobile page
  In order to be able to see all actions tags with a certain tag
  As a Tracks user
  I want to to be able to find all actions with a specific tag

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I am working on the mobile interface
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@mobile"
    And I have a project "my project" that has the following todos
      | context | description   | tags      |
      | @mobile | first action  | test, bla |
      | @mobile | second action | bla       |

  Scenario: I can follow the tag of a action to see all actions belonging to that todo
    When I go to the home page
    And I follow the tag "test"
    Then the badge should show 1
    When I go to the home page
    And I follow the tag "bla"
    Then the badge should show 2
