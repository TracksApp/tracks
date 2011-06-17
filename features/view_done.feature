Feature: Show done
  In order to see what I have completed
  As an user
  I want see my done todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have 1 completed todos with a note

  Scenario: Visit done overview page
    When I go to the done page
    Then I should see "Last Completed Actions"
    And I should see "Last Completed Projects"
    And I should see "Last Completed Repeating Actions"
    
  Scenario: Home page links to show all completed todos
    When I go to the home page
    Then I should see "Completed actions"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the done actions page

  Scenario Outline: I can see all todos completed in the last timeperiod
    Given I have a context called "@pc"
    And I have a project called "test"
    And I have 1 completed todos in project "test" in context "@pc"
    When I go to the <page>
    Then I should see "todo 1"
    And I should see "Completed today"
    And I should see "Completed in the rest of this week"
    And I should see "Completed in the rest of this month"
    
    Scenarios:
    | page                                 | 
    | done actions page                    | 
    | done actions page for context "@pc"  | 
    | done actions page for project "test" |
    
  Scenario: I can see all todos completed
    When I go to the done actions page
    And I should see "You can see all completed actions here"
    When I follow "here"
    Then I should be on the all done actions page
    
  Scenario: I can browse all todos completed by page
    Given I have 50 completed todos with a note
    When I go to the all done actions page    
    Then I should see the page selector
    When I follow "2"
    Then I should be on the all done actions page
    And the page should be "2"
    
  Scenario: The context page for a context shows a link to all completed actions
    Given I have a context called "@pc"
    And I have 1 completed todos in context "@pc"
    When I go to the context page for "@pc"
    Then I should see "Completed actions"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the done actions page for context "@pc"

  Scenario: The project page for a project shows a link to all completed actions
    Given I have a context called "@pc"
    And I have a project called "test"
    And I have 1 completed todos in project "test" in context "@pc"
    When I go to the "test" project
    Then I should see "Completed actions"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the done actions page for project "test"
