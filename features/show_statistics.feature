Feature Show statistics
  In order to see what I have got done
  As an user
  I want see my statistics

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |

  Scenario: Show statistics with no history
    Given I have logged in as "testuser" with password "secret"
    And I have no todos
    When I go to the statistics page
    Then I should see "Totals"
    And I should see " More statistics will appear here once you have added some actions."

  Scenario: Show statistics with history
    Given I have logged in as "testuser" with password "secret"
    And I have 5 todos
    And I have 2 deferred todos
    And I have 2 completed todos
    When I go to the statistics page
    And I should see "You have 7 incomplete actions"
    And I should see "of which 2 are deferred actions"
    And I should see "you have a total of 9 actions"
    And I should see "2 of these are completed" 
    Then I should see "Totals"
    And I should see "Actions"
    And I should see "Contexts"
    And I should see "Projects"
    And I should see "Tags"
    
  Scenario: Click through to see chart of all actions per month
    Given I have logged in as "testuser" with password "secret"
    And I have 5 todos
    When I go to the statistics page
    And I click on the chart for actions done in the last 12 months
    Then I should see a chart
    And I should see "to return to the statistics page"
    
  Scenario: Click through to see all incomplete actions of a week
    Given I have logged in as "testuser" with password "secret"
    And I have 5 todos
    And I have 2 deferred todos
    When I go to the statistics page
    And I click on the chart for running time of all incomplete actions
    Then I should see a chart
    And I should see "Actions selected from week"
    And I should see 7 todos
    And I should see "to return to the statistics page"
    And I should see "to show the actions from week 0 and further"

  Scenario: Click through to see all incomplete visible actions of a week
    Given I have logged in as "testuser" with password "secret"
    And I have 5 todos
    And I have 3 deferred todos
    When I go to the statistics page
    And I click on the chart for running time of all incomplete actions
    Then I should see a chart
    And I should see "Actions selected from week"
    And I should see 5 todos
    And I should see "to return to the statistics page"
    And I should see "to show the actions from week 0 and further"
