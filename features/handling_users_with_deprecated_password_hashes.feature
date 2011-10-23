Feature: Handling users with deprecated passwords hashes
  In order to have my password hashed with BCrypt
  As a user with password hashed with SHA1
  I have to be redirected to the password resetting form

  Background:
    Given the following user records with hash algorithm
      | login         | password        | algorithm  |
      | new_hash_user | first_secret    | bcrypt     |
      | old_hash_user | another_secret  | sha1       |

  Scenario Outline: A user with SHA1 password
    Given I have logged in as "old_hash_user" with password "another_secret"
    When I go to the <name> page
    Then I should be redirected to the change password page
    And I should see "You have to reset your password"
    When I change my password to "newer_better_password"
    Then I should be redirected to the preference page

    Examples:
      | name        |
      | home        |
      | preferences |
      | notes       |
      | tickler     |

  Scenario: A user with SHA1 password goes straight to the change password page
    Given I have logged in as "old_hash_user" with password "another_secret"
    When I go to the change password page
    Then I should be on the change password page

  Scenario: A user with BCrypt password
    Given I have logged in as "new_hash_user" with password "first_secret"
    When I go to the homepage
    Then I should be on the homepage
