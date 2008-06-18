Story: Existing user logging in 

  As an existing user
  I want to log in with my username and password
  So that I can securely get things done
  
  Scenario: Login success
    Given an admin user Reinier with the password abracadabra
    And Reinier is not logged in
    When Reinier visits the login page
    And Reinier successfully submits the login form
    Then Reinier should see the tasks listing page
    And Reinier should see the message Login successful
    
  Scenario: Login failure
    Given an admin user Reinier with the password abracadabra
    And Reinier is not logged in
    When Reinier visits the login page
    And Reinier submits the login form with an incorrect password
    Then Reinier should see the login page again
    And Reinier should see the message Login unsuccessful
  