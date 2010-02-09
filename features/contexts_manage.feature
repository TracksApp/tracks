Feature: Manage contexts

  In order to manage my contexts
  As a Tracks user
  I want to view, edit, add, or remove contexts

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
  
  @selenium
  Scenario: In place edit of context name
    Given I have a context called "Errands"
    When I visits the context page for "Errands"
    And I edit the context name in place to be "OutAndAbout"
    Then I should see the context name is "OutAndAbout"
    When I go to the contexts page
    Then he should see that a context named "Errands" is not present
    And he should see that a context named "OutAndAbout" is present

  @selenium
  Scenario: Delete context from context page
    Given I have a context called "@computer"
    When I go to the contexts page
    Then the badge should show 1
    When I delete the context "@computer"
    Then he should see that a context named "@computer" is not present
    And the badge should show 0

  @selenium
  Scenario: Delete context from context page right after an edit
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    When I delete the context "@laptop"
    Then he should see that a context named "@laptop" is not present
    And the badge should show 0

  @selenium
  Scenario: Edit context from context twice
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    And I edit the context to rename it to "@ipad"
    Then he should see that a context named "@computer" is not present
    And he should see that a context named "@laptop" is not present
    And he should see that a context named "@ipad" is present
    And the badge should show 1
