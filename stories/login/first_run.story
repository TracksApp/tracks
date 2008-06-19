Story: First run shows admin signup

  As a user who just installed Tracks
  I want to create an admin account
  So that I have control over all preferences and users
  
  Scenario: Successful signup
    Given no users exist
    And a visitor named Reinier
    When Reinier visits the site
    Then he should see a signup form
    When Reinier successfully submits the signup form
    Then Reinier should see the tasks listing page
    And Reinier should be an admin
  