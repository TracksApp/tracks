Feature: Manage the list of contexts

  In order to keep track and manage all of my contexts
  As a Tracks user
  I want to manage my list of contexts

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
  
  @selenium, @wip
  Scenario: Delete context from context page should update badge
    Given I have a context called "@computer"
    When I go to the contexts page
    Then the badge should show 1
    When I delete the context "@computer"
    Then he should see that a context named "@computer" is not present
    And the badge should show 0

  @selenium, @wip
  Scenario: Delete context from context page right after an edit
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    When I delete the context "@laptop"
    Then he should see that a context named "@laptop" is not present
    And the badge should show 0

  @selenium, @wip
  Scenario: Edit context from context twice
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    And I edit the context to rename it to "@ipad"
    Then he should see that a context named "@computer" is not present
    And he should see that a context named "@laptop" is not present
    And he should see that a context named "@ipad" is present
    And the badge should show 1

  @selenium
  Scenario Outline: Add a new context with state
    Given I have the following contexts
      | name  | hide   |
      | @ipad | true   |
      | @home | false  |
    When I go to the contexts page
    And I add a new <state> context "<name>"
    Then I should see the context "<name>" under "<state>"

    Examples:
    | state  | name   |
    | active | @phone |
    | hidden | @hidden|
