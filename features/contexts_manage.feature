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
