Feature: Add new next action from mobile page
  In order to be able to add next actions from the mobile interface
  As a Tracks user
  I want to to be able to add a new next actions from the mobile interface and prepopulate the context and / or project of the prior page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I am working on the mobile interface
    And I have logged in as "testuser" with password "secret"
    And I have a context called "a context"
    And I have a project "test project" with a default context of "test context"

  Scenario Outline: The new action form is prefilled with context and project
    Given I am on the <page>
    When I follow "New"
    Then the selected project should be "<project>"
    And the selected context should be "<context>"

    Scenarios: # empty means no selected, i.e. first in list is shown
      | page                            | project      | context      |
      | home page                       |              |              |
      | tickler page                    |              |              |
      | "test project" project          | test project | test context |
      | context page for "test context" |              | test context |
      | tag page for "starred"          |              |              |

  Scenario: I can add a new todo using the mobile interface
    Given I am on the home page
    Then the badge should show 0
    When I follow "New"
    And I fill in "Description" with "test me"
    And I press "Create"
    Then I should see "test me"
    And the badge should show 1
