Feature: View the list of contexts from mobile
  In order to be able to see all contexts from the mobile interface
  As a Tracks user
  I want to to be able to see a list of project

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I am working on the mobile interface
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@mobile"
    And I have a project "test project" that has the following todos
      | context | description | 
      | @mobile | test action | 

  Scenario: I can go to a context from the mobile context list page
    Given I have a todo "test mobile page" in the context "@mobile"
    And I am on the contexts page
    Then I should see "@mobile"
    When I follow "@mobile"
    Then the badge should show 2
    And I should see "@mobile"
