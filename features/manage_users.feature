Feature: Manage users
  In order to be able to manage the users able to use Tracks
  As the administrator of this installed Tracks
  I want to add and delete accounts of users

  Background:
    Given the following user records
      | login    | password | is_admin |
      | testuser | secret   | false    |
      | admin    | secret   | true     |
    And I have logged in as "admin" with password "secret"

  Scenario: Show all accounts
    When I go to the manage users page
    Then I should see "testuser"
    And I should see "admin"

  Scenario: Add new account
    When I go to the manage users page
    And I follow "Sign up new user"
    Then I should be on the signup page
    When I submit the signup form with username "new.user", password "secret123" and confirm with "secret123"
    Then I should be on the manage users page
    And I should see "new.user"

  @javascript
  Scenario: Delete account from users page
    When I go to the manage users page
    And I delete the user "testuser"
    Then I should see that a user named "testuser" is not present