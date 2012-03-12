Feature: Integrate Tracks in various ways
  In order to use tracks with other software
  As a Tracks user
  I want to be informed about the various ways to integrate tracks

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have the following contexts:
      | context |
      | @pc     |
      | @home   |
      | @shops  |
      | @boss   |

  Scenario: I cannot see scripts when I do not have a context
    Given I have no contexts
    When I go to the integrations page
    Then I should see a message that you need a context to see scripts

  Scenario: I can see scripts when I have one or more contexts
    When I go to the integrations page
    Then I should see scripts

  @javascript
  Scenario: The scripts on the page should be prefilled with the first context
    When I go to the integrations page
    Then I should see a script "applescript1" for "@pc"

  @javascript
  Scenario Outline: When I select a different context the example scripts should change accordingly
    When I go to the integrations page
    When I select "<context1>" from "<context-list>"
    Then I should see a script "<script>" for "<context1>"
    When I select "<context2>" from "<context-list>"
    Then I should see a script "<script>" for "<context2>"

    Examples:
      | context1 | context2 | context-list          | script       |
      | @home    | @boss    | applescript1-contexts | applescript1 |
      | @shops   | @home    | applescript2-contexts | applescript2 |
      | @boss    | @shops   | quicksilver-contexts  | quicksilver  |
