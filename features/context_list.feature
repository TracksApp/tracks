Feature: Manage the list of contexts
  In order to keep track and manage all of my contexts
  As a Tracks user
  I want to manage my list of contexts

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: The list of contexts contain all contexts
    Given I have the following contexts
      | context  | hide  |
      | @ipad    | false |
      | @home    | false |
      | @boss    | false |
    When I go to the contexts page
    Then I should see "@ipad"
    And I should see "@home"
    And I should see "@boss"
    And the badge should show 3

  Scenario: Clicking on a context takes me to the context page
    Given I have a context called "@computer"
    When I go to the contexts page
    And I follow "@computer"
    Then I should be on the context page for "@computer"

  Scenario: The context view shows all todos
    Given I have a todo "foo" in the context "@bar" which is due tomorrow
    Given I have a deferred todo "foo2" in the context "@bar"
    Given I have a todo "foo3" in the context "@bar"
    When I go to the contexts page
    And I follow "@bar"
    Then I should be on the context page for "@bar"
    And the badge should show 3

  @javascript
  Scenario: Delete context from context page should update badge
    Given I have a context called "@computer"
    And I have a context called "@ipad"
    When I go to the contexts page
    Then the badge should show 2
    And the context list badge for active contexts should show 2
    When I delete the context "@computer"
    Then I should see that a context named "@computer" is not present
    And the badge should show 1
    And the context list badge for active contexts should show 1

  @javascript
  Scenario: Delete last context from context page should remove the contexts container
    Given I have a context called "@computer"
    And I have a hidden context called "@ipad"
    And I have a closed context called "@ibm-pc"
    When I go to the contexts page
    And I should see that the context container for active contexts is present
    And I should see that the context container for hidden contexts is present
    And I should see that the context container for closed contexts is present
    When I delete the context "@computer"
    Then I should see that a context named "@computer" is not present
    And I should see empty message for active contexts
    When I delete the context "@ipad"
    Then I should see that a context named "@ipad" is not present
    And I should see empty message for hidden contexts
    When I delete the context "@ibm-pc"
    Then I should see that a context named "@ibm-pc" is not present
    And I should see empty message for closed contexts

  @javascript 
  Scenario: Delete context from context page right after an edit
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    When I delete the context "@laptop"
    Then he should see that a context named "@laptop" is not present
    And the badge should show 0

  @javascript 
  Scenario: Edit context from context twice
    Given I have a context called "@computer"
    When I go to the contexts page
    And I edit the context to rename it to "@laptop"
    And I edit the context to rename it to "@ipad"
    Then he should see that a context named "@computer" is not present
    And he should see that a context named "@laptop" is not present
    And he should see that a context named "@ipad" is present
    And the badge should show 1

  @javascript 
  Scenario Outline: Showing a new context with state
    Given I have the following contexts
      | context  | hide  |
      | @ipad    | true  |
      | @home    | false |
    When I go to the contexts page
    And I add a new <state> context "<name>"
    Then I should see the context "<name>" under "<state>"

    Examples:
      | state  | name    |
      | active | @phone  |
      | hidden | @hidden |

  @javascript
  Scenario: Showing a new context with state
    When I go to the contexts page
    Then I should see empty message for active contexts
    And I should see empty message for hidden contexts
    And I should see empty message for closed contexts
    When I add a new active context "@active"
    Then I should see the context "@active" under "active"
    And I should not see empty message for active contexts
    When I add a new hidden context "@hidden"
    Then I should see the context "@hidden" under "hidden"
    And I should not see empty message for hidden contexts
    When I edit the state of context "@hidden" to closed
    Then I should not see empty message for closed contexts
    And I should see the context "@hidden" under "closed"

  @javascript
  Scenario: I can drag and drop to order the contexts
    Given I have the following contexts
      | context |
      | @ipad   |
      | @home   |
      | @boss   |
    When I go to the contexts page
    Then context "@ipad" should be above context "@home"
    When I drag context "@home" above context "@ipad"
    Then context "@home" should be above context "@ipad"

  @javascript
  Scenario: Hiding and unhiding the new context form
    When I go to the contexts page
    Then the new context form should be visible
    When I follow "Hide form"
    Then the new context form should not be visible
    When I follow "Create a new context"
    Then the new context form should be visible