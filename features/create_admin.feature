Feature: Signup new users
  In order to be able to administer Tracks
  As a user who just installed Tracks
  I want to create an admin account

  Background:
    Given the following user records
      | login    | password | is_admin |
      | testuser | secret   | false    |
      | admin    | secret   | true     |

  Scenario: Successful signup
    Given no users exists
    When I go to the homepage
    Then I should be redirected to the signup page
    When I submit the signup form with username "admin", password "secret" and confirm with "secret"
    Then I should be on the homepage
    And I should be an admin

  @wip
  Scenario: Signup should be refused when password and confirmation is not the same
    Given no users exists
    When I go to the signup page
    And I submit the signup form with username "admin", password "secret" and confirm with "error"
    Then I should be redirected to the signup page
    And I should see "Password doesn't match confirmation"

  Scenario: With public signups turned off, signup should be refused when an admin user exists
    Given public signups are turned off
    When I go to the signup page
    Then I should see "You don't have permission to sign up for a new account."

  Scenario: With public signups turned on, signup should possible when an admin user exists
    Given public signups are turned on
    When I go to the signup page
    Then I should see "Sign up a new user"
