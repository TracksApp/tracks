Feature: Existing user logging in 

  In order to keep my things private
  As an existing user
  I want to log in with my username and password

  Background:
    Given the following user records
      | login    | password | is_admin |
      | testuser | secret   | false    |
      | admin    | secret   | true     |

  Scenario Outline: Succesfull and unsuccesfull login
    When I go to the login page
    And I submit the login form as user "<user>" with password "<password>"
    Then I should be <there>
    And I should see "<message>"

    Examples:
    | user  | password | there                       | message            |
    | admin | secret   | redirected to the home page | Login successful   |
    | admin | wrong    | on the login page           | Login unsuccessful |

  Scenario: Accessing a secured page when not logged in
    When I go to the home page
    Then I should be redirected to the login page    