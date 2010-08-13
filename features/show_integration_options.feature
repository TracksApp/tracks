Feature: Integrate Tracks in various ways

  In order to use tracks with other software
  As a Tracks user
  I want to be informed about the various ways to integrate tracks

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I cannot see scripts when I do not have a context
    Given I have no contexts
    When I go to the integrations page
    Then I should see a message that you need a context to see scripts

  Scenario: I can see scripts when I have one or more contexts
    Given I have a context called "@pc"
    When I go to the integrations page
    Then I should see scripts

  @selenium
  Scenario: When I select a different context the example scripts should change accoordingly
    Given I have the following contexts:
      | context |
      | @pc     |
      | @home   |
      | @shops  |
      | @boss   |
    When I go to the integrations page
    Then I should see a script "applescript1" for "@pc"
    When I select "@home" from "applescript1-contexts"
    Then I should see a script "applescript1" for "@home"
    When I select "@shops" from "applescript2-contexts"
    Then I should see a script "applescript2" for "@shops"
    When I select "@boss" from "quicksilver-contexts"
    Then I should see a script "quicksilver" for "@boss"
