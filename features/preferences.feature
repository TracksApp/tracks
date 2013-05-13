Feature: Manage preferences
  In order to customize Tracks to my needs
  As a Tracks user
  I want to be be able change my preferences

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: I can change my password
    When I go to the preferences page
    And I set the password and confirmation to "secret123"
    When I log out of Tracks
    And I go to the login page
    And I submit the login form as user "testuser" with password "secret"
    Then I should see "Login unsuccessful"
    When I submit the login form as user "testuser" with password "secret123"
    Then I should see "Login successful"

  Scenario: I can leave password field empty and the password will not be changed
    When I go to the preferences page
    And I set the password and confirmation to ""
    When I log out of Tracks
    And I go to the login page
    And I submit the login form as user "testuser" with password ""
    Then I should see "Login unsuccessful"
    When I submit the login form as user "testuser" with password "secret"
    Then I should see "Login successful"

  Scenario: The password and the confirmation need to be the same
    When I go to the preferences page
    And I set the password to "secret" and confirmation to "wrong"
    Then I should see "Password confirmation doesn't match confirmation"

  Scenario: I can edit preferences
    When I go to the preferences page
    Then I should see "Logout (testuser)"
    When I edit my last name to "Tester"
    Then I should see "Logout (Tester)"