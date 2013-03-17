Feature: Edit a next action from the mobile view
  In order to manage a next action
  As a Tracks user
  I want to to be able to edit a next action

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I am working on the mobile interface
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@mobile"
    And I have a project "test project" that has the following todos
      | context | description |
      | @mobile | test action |

  Scenario: I can edit an action on the mobile page
    When I am on the home page
    Then the badge should show 1
    And I should see "test action"
    When I follow "test action"
    Then I should see "Actions"
    When I press "Edit action"
    Then I should see "Description"
    And I fill in "Description" with "changed action"
    And I press "Update"
    Then I should see "changed action"
    And I should not see "test action"
    When I follow "changed action"
    And I press "Mark complete"
    Then I should see "changed action" in the completed section of the mobile site

  Scenario: Navigate from home page
    move this to separate features when other scenarios are created for these features
    When I am on the home page
    Then the badge should show 1
    When I follow "Tickler"
    Then the badge should show 0
    When I follow "Feeds"
    Then I should see "Last 15 actions"

  Scenario: I can defer an action on the mobile page
    When I am on the home page
    Then the badge should show 1
    And I should see "test action"
    When I follow "test action"
    And I press "Defer 1 day"
    Then I should see "Currently there are no incomplete actions"
    When I follow "Tickler"
    Then I should see "test action"
