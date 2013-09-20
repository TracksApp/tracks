Feature: Create project from template on console
  In order to be able to create a project from a template
  As a user who has installed Tracks with console access
  I want to run the script to add projects and actions from a template
  
  These scenarios are tagged javascript so that there is a Tracks server running
  to use from the command line script

  Background:
    Given the following user records
      | login    | password | is_admin |
      | testuser | secret   | false    |
      | admin    | secret   | true     |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "Context A"
  
  @javascript @aruba 
  Scenario: Create a project with one task
    Given a template that looks like
      """
      My first project
      .My first task in this project
      """
    When I execute the template script
    Then I should have a project called "My first project"
    And I should have 1 todo in project "My first project"
    
  @javascript @aruba 
  Scenario: Create a project with dependent tasks
    Given a template that looks like
      """
      My first project
      .Todo
      ^Dependent
      """
    When I execute the template script
    Then the successors of "Todo" should include "Dependent"
