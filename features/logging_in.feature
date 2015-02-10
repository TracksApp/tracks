Feature: Existing user logging in
  In order to keep my things private
  As an existing user
  I want to log in with my username and password

  Background:
    Given the following user records
      | login    | password | is_admin | first_name | last_name |
      | testuser | secret   | false    | Test       | User      |
      | admin    | secret   | true     | Admin      | User      |

  Scenario Outline: Successful and unsuccessful login
    When I go to the login page
    And I submit the login form as user "<user>" with password "<password>"
    Then I should be <there>
    And I should see "<message>"

    Examples:
      | user  | password | there                       | message            |
      | admin | secret   | redirected to the home page | Login successful   |
      | admin | wrong    | on the login page           | Login unsuccessful |

  Scenario Outline: Unauthorized users cannot access Tracks and need to log in first
    Given there exists a project called "top secret" for user "testuser"
    And there exists a context called "@secret location" for user "testuser"
    When I go to the <page>
    Then I should be redirected to the login page
    When I submit the login form as user "testuser" with password "secret"
    Then I should be redirected to the <next page>
    And I should see "<logout>"

    Examples:
      | page                                                    | next page                                               | logout             |
      | home page                                               | home page                                               | Logout (Test User) |
      | contexts page                                           | contexts page                                           | Logout (Test User) |
      | projects page                                           | projects page                                           | Logout (Test User) |
      | notes page                                              | notes page                                              | Logout (Test User) |
      | recurring todos page                                    | recurring todos page                                    | Logout (Test User) |
      | statistics page                                         | statistics page                                         | Logout (Test User) |
      | manage users page                                       | manage users page                                       | 401 Unauthorized   |
      | integrations page                                       | integrations page                                       | Logout (Test User) |
      | starred page                                            | starred page                                            | Logout (Test User) |
      | tickler page                                            | tickler page                                            | Logout (Test User) |
      | calendar page                                           | calendar page                                           | Logout (Test User) |
      | feeds page                                              | feeds page                                              | Logout (Test User) |
      | preference page                                         | preference page                                         | Logout (Test User) |
      | export page                                             | export page                                             | Logout (Test User) |
      | rest api docs page                                      | rest api docs page                                      | Logout (Test User) |
      | search page                                             | search page                                             | Logout (Test User) |
      | "top secret" project for user "testuser"                | "top secret" project for user "testuser"                | Logout (Test User) |
      | context page for "@secret location" for user "testuser" | context page for "@secret location" for user "testuser" | Logout (Test User) |

  @javascript
  Scenario: When session expires, you should be logged out
    When I go to the login page
    And I submit the login form as user "testuser" with password "secret"
    Then I should be on the home page
    When my session expires
    Then I should be on the login page