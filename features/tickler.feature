Feature: Manage deferred todos
  In order to hide todos that require attention in the future and not now
  As a Tracks user
  I want to defer these and manage them in a tickler

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And there exists a project "manage me" for user "testuser"
    And I have logged in as "testuser" with password "secret"

  @javascript
  Scenario Outline: I can add a deferred todo and it will show in the tickler
    # also adding the first deferred todo will hide the empty message
    Given I have a context called "test"
    And I have selected the view for group by <grouping>
    When I go to the tickler page
    Then I should see the empty tickler message
    When I submit a new deferred action with description "a new next action"
    Then I should see "a new next action"
    And I should not see the empty tickler message

    Scenarios:
      | grouping |
      | context  |
      | project  |

  @javascript
  Scenario Outline: Editing the description of a todo in the tickler updated the todo
    Given I have a deferred todo "not yet now"
    And I have selected the view for group by <grouping>
    When I go to the tickler page
    Then I should see "not yet now"
    When I edit the description of "not yet now" to "almost"
    Then I should not see "not yet now"
    And I should see "almost"

    Scenarios:
      | grouping |
      | context  |
      | project  |

  @javascript
  Scenario Outline: Editing the container of a todo moves it to the new container
    Given I have a context called "A"
    And I have a context called "B"
    And I have a project called "pA"
    And I have a project called "pB"
    And I have a deferred todo "not yet now" in the context "A" in the project "pA"
    And I have selected the view for group by <grouping>
    When I go to the tickler page
    Then I should see "not yet now" in the <first container>
    When I edit the <grouping> of "not yet now" to <new container name>
    Then I should see "not yet now" in the <new container>
    And I should not see "not yet now" in the <first container>

    Scenarios:
      | grouping | first container            | new container name | new container              |
      | context  | context container for "A"  | "B"                | context container for "B"  |
      | project  | project container for "pA" | "pB"               | project container for "pB" |

  @javascript
  Scenario Outline: Removing the show from date from a todo removes it from the tickler
    Given I have a deferred todo "not yet now"
    And I have selected the view for group by <grouping>
    When I go to the tickler page
    Then I should see "not yet now"
    When I remove the show from date from "not yet now"
    Then I should not see "not yet now"
    And I should see the empty tickler message
    When I go to the home page
    Then I should see "not yet now"

    Scenarios:
      | grouping |
      | context  |
      | project  |

  Scenario: Opening the tickler page shows me all deferred todos
    Given I have a deferred todo "not yet now"
    And I have a todo "now is a good time"
    When I go to the tickler page
    Then I should see "not yet now"
    And I should not see "now is a good time"

  @javascript
  Scenario Outline: I can mark an action complete from the tickler
    Given I have a deferred todo "not yet now"
    And I have selected the view for group by <grouping>
    When I go to the tickler page
    And I mark "not yet now" as complete
    Then I should not see "not yet now"
    When I go to the done page
    Then I should see "not yet now"

    Scenarios:
      | grouping |
      | context  |
      | project  |

  Scenario: Opening the tickler page shows the deferred todos in order
    Given I have a deferred todo "show tomorrow" in the context "Context B" deferred by 1 day
    And I have a deferred todo "show in a year" in the context "Context B" deferred by 365 days
    And I have a deferred todo "show in a week" in the context "Context B" deferred by 7 days
    When I go to the tickler page
    Then I should see "show tomorrow" before "show in a week"
    And I should see "show tomorrow" before "show in a year"
    And I should see "show in a week" before "show in a year"
