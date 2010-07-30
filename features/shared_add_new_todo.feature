Feature: Add new next action from every page

  In order to quickly add a new next action
  As a Tracks user
  I want to to be able to add one or more new next actions from every page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "test context"
    And I have a project "test project" with 1 todos

  @selenium
  Scenario Outline: I can hide the input form for single next action on a page
    When I <action> the <page>
    Then the single action form should be visible
    When I follow "« Hide form"
    Then the single action form should not be visible

      Scenarios:
      | action | page                           |
      | go to  | home page                      |
      | go to  | tickler page                   |
      | visit  | project page for "test project"|
      | visit  | context page for "test context"|
      | visit  | tag page for "starred"         |

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
      | action | page                           |
      | go to  | home page                      |
      | go to  | tickler page                   |
      | visit  | project page for "test project"|
      | visit  | context page for "test context"|
      | visit  | tag page for "starred"         |

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
      | action | page                           |
      | go to  | home page                      |
      | go to  | tickler page                   |
      | visit  | project page for "test project"|
      | visit  | context page for "test context"|
      | visit  | tag page for "starred"         |

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
      | action | page                           |
      | go to  | home page                      |
      | go to  | tickler page                   |
      | visit  | project page for "test project"|
      | visit  | context page for "test context"|
      | visit  | tag page for "starred"         |

  @selenium
  Scenario Outline: I can add a todo from several pages 
     When I <action> the <page>
     And I submit a new action with description "a new next action"
     Then I should <see> "a new next action"

      Scenarios:
      | action | page                           | see    |
      | go to  | home page                      | see    |
      | go to  | tickler page                   | not see|
      | visit  | project page for "test project"| see    |
      | visit  | context page for "test context"| see    |
      | visit  | tag page for "starred"         | not see|

  @selenium
  Scenario Outline: I can add multiple todos from several pages
     When I <action> the <page>
     And I follow "Add multiple next actions"
     And I submit multiple actions with using
     """
     one new next action
     another new next action
     """
     Then I should <see> "one new next action"
     And I should <see> "another new next action"
     And the badge should show <badge>
     And the number of actions should be <count>

      Scenarios:
      | action | page                           | see    | badge | count |
      | go to  | home page                      | see    | 3     | 3     |
      | go to  | tickler page                   | not see| 0     | 3     |
      | visit  | project page for "test project"| see    | 3     | 3     |
      | visit  | context page for "test context"| see    | 2     | 3     |
      | visit  | tag page for "starred"         | not see| 0     | 3     |

  @selenium
  Scenario: I need to fill in at least one description and a context
    When I go to the home page
    And I follow "Add multiple next actions"
    And I submit the new multiple actions form with "", "", "", ""
    Then I should see "You need to submit at least one next action"
    When I submit the new multiple actions form with "one", "", "", ""
    Then I should see "Context can't be blank"
    When I fill the multiple actions form with "", "a project", "test context", "tag"
    And I submit the new multiple actions form with
    """

    
    """ 
    Then I should see "You need to submit at least one next action"
