Feature: Existing user logging in 

  In order to keep my things private
  As an existing user
  I want to log in with my username and password
  
  Scenario: Succesfull login
    Given an admin user exists
    When I go to the login page
    And I successfully submit the login form as an admin user
    Then I should be redirected to the home page
    And I should see "Login successful"
    
  Scenario: Unsuccesfull login
    Given an admin user exists
    When I go to the login page
    And I submit the login form as an admin user with an incorrect password
    Then I should be on the login page
    And I should see "Login unsuccessful"

  Scenario: Accessing a secured page when not logged in
    Given an admin user exists
    When I go to the home page
    Then I should be redirected to the login page
    