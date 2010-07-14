Feature: Add new next action from every page

  In order to quickly add a new next action
  As a Tracks user
  I want to to be able to add one or more new next actions from every page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "test"
    And I have a project "test" with 1 todos

  @selenium
  Scenario Outline: I can hide the input form for single next action on a page
    When I <action> the <page>
    Then the single action form should be visible
    When I follow "« Hide form"
    Then the single action form should not be visible

      Scenarios:
      | action | page                   |
      | go to  | home page              |
      | go to  | tickler page           |
      | visit  | project page for "test"|
      | visit  | context page for "test"|
      | visit  | tag page for "starred" |

  @selenium
  Scenario Outline: I can hide the input form for multiple next actions
    When I <action> the <page>
    Then the single action form should be visible
    When I follow "Add multiple next actions"
    Then the multiple action form should be visible
    When I follow "« Hide form"
    Then the single action form should not be visible
    And the multiple action form should not be visible

      Scenarios:
      | action | page                   |
      | go to  | home page              |
      | go to  | tickler page           |
      | visit  | project page for "test"|
      | visit  | context page for "test"|
      | visit  | tag page for "starred" |

  @selenium
  Scenario Outline: I can hide the input form and then choose both input forms
    When I <action> the <page>
    Then the single action form should be visible
    When I follow "« Hide form"
    Then the single action form should not be visible
    When I follow "Add multiple next actions"
    Then the multiple action form should be visible
    When I follow "« Hide form"
    Then the single action form should not be visible
    And the multiple action form should not be visible

      Scenarios:
      | action | page                   |
      | go to  | home page              |
      | go to  | tickler page           |
      | visit  | project page for "test"|
      | visit  | context page for "test"|
      | visit  | tag page for "starred" |

  @selenium
  Scenario Outline: I can switch forms for single next action to multiple next actions
    When I <action> the <page>
    Then the single action form should be visible
    When I follow "Add multiple next actions"
    Then the single action form should not be visible
    And the multiple action form should be visible
    When I follow "Add single next action"
    Then the single action form should be visible
    And the multiple action form should not be visible

      Scenarios:
      | action | page                   |
      | go to  | home page              |
      | go to  | tickler page           |
      | visit  | project page for "test"|
      | visit  | context page for "test"|
      | visit  | tag page for "starred" |
