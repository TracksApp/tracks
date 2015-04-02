Feature: Add a todo to Tracks on console
  In order to be able to add a todo from the command line 
  As a user who has installed Tracks with console access
  I want to run the script to add a todo
  
  These scenarios are tagged javascript so that there is a Tracks server running
  to use from the command line script

  Background:
    Given the following user records
      | login    | password | is_admin |
      | testuser | secret   | false    |
      | admin    | secret   | true     |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "Context A"
    And I have a project called "Project A"

  @javascript @aruba
  Scenario: Create a single todo 
    Given a console input that looks like
      """
      a new todo
      """
    When I execute the add-todo script
    Then I should have 1 todo in project "Project A"
    
  @javascript @aruba
  Scenario: Create multiple todos
    Given a console input that looks like
      """
      todo 1
      todo 2

      """
    When I execute the add-todo script
    Then I should have 2 todos in project "Project A"
