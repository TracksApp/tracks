Feature: Get all sorts of lists from Tracks
  In order to get reports on todos managed by Tracks
  As a Tracks user
  I want to be be able to select a feed

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
    And I have the following projects:
      | project_name    |
      | Test feedlist   |
      | Get release out |

  Scenario: I cannot see context scripts when I do not have a context
    Given I have no contexts
    When I go to the feeds page
    Then I should see a message that you need a context to get feeds for contexts

  Scenario: I cannot see proejct scripts when I do not have a project
    Given I have no projects
    When I go to the feeds page
    Then I should see a message that you need a project to get feeds for projects

  Scenario: I can see scripts when I have one or more contexts
    When I go to the feeds page
    Then I should see feeds for projects
    And I should see "Test feedlist" as the selected project
    And I should see feeds for contexts
    And I should see "@pc" as the selected context

  @javascript
  Scenario Outline: I can select the item for getting feeds for that item
    When I go to the feeds page
    And I select "<item>" from "<item-list>"
    Then I should see feeds for "<item>" in list of "<item-type>"

    Examples:
      | item            | item-list     | item-type |
      | @boss           | feed-contexts | context   |
      | Get release out | feed-projects | project   |
