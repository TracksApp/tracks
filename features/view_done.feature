Feature: Show done
  In order to see what I have completed
  As an user
  I want see my done todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |

  Scenario: Visit done page
    Given I have logged in as "testuser" with password "secret"
    And I have 1 completed todos with a note
    When I go to the done page
    Then I should see "Completed in the last 24 hours"
