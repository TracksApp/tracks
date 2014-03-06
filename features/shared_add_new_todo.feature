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
    And I have a project "test project"

  @javascript
  Scenario Outline: I can hide the input form for single next action on a page
    When I go to the <page>
    Then the single action form should be visible
    When I follow "Hide form"
    Then the single action form should not be visible

    Scenarios:
      | page                            |
      | home page                       |
      | tickler page                    |
      | "test project" project          |
      | context page for "test context" |
      | tag page for "starred"          |

  @javascript
  Scenario Outline: I can hide the input form for multiple next actions
    When I go to the <page>
    Then the single action form should be visible
    When I follow "Add multiple next actions"
    Then the multiple action form should be visible
    When I follow "Hide form"
    Then the single action form should not be visible
    And the multiple action form should not be visible

    Scenarios:
      | page                            |
      | home page                       |
      | tickler page                    |
      | "test project" project          |
      | context page for "test context" |
      | tag page for "starred"          |

  @javascript
  Scenario Outline: I can hide the input form and then choose both input forms
    When I go to the <page>
    Then the single action form should be visible
    When I follow "Hide form"
    Then the single action form should not be visible
    When I follow "Add multiple next actions"
    Then the multiple action form should be visible
    When I follow "Hide form"
    Then the single action form should not be visible
    And the multiple action form should not be visible

    Scenarios:
      | page                            |
      | home page                       |
      | tickler page                    |
      | "test project" project          |
      | context page for "test context" |
      | tag page for "starred"          |

  @javascript
  Scenario Outline: I can switch forms for single next action to multiple next actions
    When I go to the <page>
    Then the single action form should be visible
    When I follow "Add multiple next actions"
    Then the single action form should not be visible
    And the multiple action form should be visible
    When I follow "Add a next action"
    Then the single action form should be visible
    And the multiple action form should not be visible

    Scenarios:
      | page                            |
      | home page                       |
      | tickler page                    |
      | "test project" project          |
      | context page for "test context" |
      | tag page for "starred"          |

  @javascript
  Scenario Outline: I can add a todo from several pages
    Given I have selected the view for group by <grouping>
    When I go to the <page>
    And I submit a new action with description "a new next action" 
    Then I should <see> the todo "a new next action"

    Scenarios:
      | page                            | grouping | see     |
      | home page                       | context  | see     |
      | home page                       | project  | see     |
      | tickler page                    | context  | not see |
      | tickler page                    | project  | not see |
      | "test project" project          | context  | see     |
      | "test project" project          | project  | see     |
      | context page for "test context" | context  | see     |
      | context page for "test context" | project  | see     |
      | tag page for "starred"          | context  | see     |
      | tag page for "starred"          | project  | see     |

  @javascript
  Scenario Outline: I can add multiple todos from several pages
    Given I have a project "testing" with 1 todos
    And I have selected the view for group by <grouping>
    When I go to the <page>
    And I follow "Add multiple next actions"
    And I submit multiple actions with using
      """
      one new next action
      another new next action
      """
    Then I should <see> the todo "one new next action"
    And I should <see> the todo "another new next action"
    And the badge should show <badge>
    And the number of actions should be <count>

    Scenarios:
      | page                            | see     | badge | count | grouping |
      | home page                       | see     | 3     | 3     | context  |
      | home page                       | see     | 3     | 3     | project  |
      | tickler page                    | not see | 0     | 3     | context  |
      | tickler page                    | not see | 0     | 3     | project  |
      | "testing" project               | see     | 3     | 3     | context  |
      | "testing" project               | see     | 3     | 3     | project  |
      | context page for "test context" | see     | 2     | 3     | context  |
      | context page for "test context" | see     | 2     | 3     | project  |
      | tag page for "starred"          | see     | 2     | 3     | context  |
      | tag page for "starred"          | see     | 2     | 3     | project  |

  @javascript
  Scenario: Adding a todo to another project does not show the todo in project view
    Given I have a project called "another project"
    When I go to the "test project" project
    And I submit a new action with description "can you see me?" to project "another project" in the context "test context"
    Then I should not see "can you see me?"
    When I go to the "another project" project
    Then I should see "can you see me?"

  @javascript
  Scenario: Adding a deferred todo to another project does not show the todo
    # scenario for #1146
    Given I have a project called "another project"
    When I go to the "test project" project
    And I submit a deferred new action with description "a new next action" to project "another project" in the context "test context"
    Then I should not see the todo "a new next action"
    And I submit a deferred new action with description "another new next action" to project "test project" in the context "test context"
    Then I should see the todo "another new next action"

  @javascript
  Scenario Outline: Adding a todo with a new context shows the new context when page groups todos by context
    When I go to the <page>
    And I submit a new <todo> with description "do at new context" and the tags "starred" in the context "New"
    Then a confirmation for adding a new context "New" should be asked
    And the container for the context "New" should <visible>
    And the badge should show <badge>

    Scenarios:
      | page                            | todo            | badge | visible        |
      | home page                       | action          | 1     | be visible     |
      | tickler page                    | deferred action | 1     | be visible     |
      | "test project" project          | action          | 1     | not be visible |
      | context page for "test context" | action          | 1     | not be visible |
      | tag page for "starred"          | action          | 1     | be visible     |

  @javascript
  Scenario Outline: Adding a todo with a new project shows the new project when page groups todos by project
    And I have selected the view for group by project
    When I go to the <page>
    And I submit a new <todo> with description "do in new project" to project "New" with tags "starred" 
    Then the container for the project "New" should <visible>
    And the badge should show <badge>

    Scenarios:
      | page                            | todo            | badge | visible        |
      | home page                       | action          | 1     | be visible     |
      | tickler page                    | deferred action | 1     | be visible     |
      | "test project" project          | action          | 1     | not be visible |
      | context page for "test context" | action          | 1     | not be visible |
      | tag page for "starred"          | action          | 1     | be visible     |

  @javascript
  Scenario Outline: Adding a todo to a hidden project does not show the todo
    Given I have a hidden project called "hidden project"
    And I have a project called "visible project"
    And I have a context called "visible context"
    And I have a context called "other context"
    And I have selected the view for group by <grouping>
    When I go to the <page>
    And I submit a new action with description "hidden todo" to project "hidden project" with tags "test" in the context "visible context"
    Then I should <see_hidden> the todo "hidden todo"
    When I submit a new action with description "visible todo" to project "visible project" with tags "test" in the context "visible context"
    Then I should <see_visible> the todo "visible todo"

    Scenarios:
      | page                               | grouping | see_hidden | see_visible |
      | home page                          | context  | not see    | see         |
      | home page                          | project  | not see    | see         |
      | tickler page                       | context  | not see    | not see     |
      | tickler page                       | project  | not see    | not see     |
      | "visible project" project          | project  | not see    | see         |
      | "visible project" project          | context  | not see    | see         |
      | "hidden project" project           | project  | see        | not see     |
      | "hidden project" project           | context  | see        | not see     |
      | context page for "visible context" | context  | not see    | see         |
      | context page for "visible context" | project  | not see    | see         |
      | context page for "other context"   | context  | not see    | not see     |
      | context page for "other context"   | project  | not see    | not see     |
      | tag page for "starred"             | context  | not see    | not see     |
      | tag page for "starred"             | project  | not see    | not see     |
      | tag page for "test"                | context  | see        | see         |
      | tag page for "test"                | project  | see        | see         |

  @javascript 
  Scenario: Adding a todo to a hidden context from home page does not show the todo
    Given I have a context called "visible context"
    And I have a hidden context called "hidden context"
    When I go to the home page
    And I submit a new action with description "a new todo" in the context "visible context"
    Then I should see "a new todo"
    When I submit a new action with description "another new todo" in the context "hidden context"
    Then I should not see "another new todo"

  @javascript
  Scenario: Adding a todo to a context shows the todo in that context page
    Given I have a context called "visible context"
    And I have a hidden context called "hidden context"
    When I go to the context page for "visible context"
    And I submit a new action with description "a new todo" in the context "visible context"
    Then I should see "a new todo"
    When I go to the context page for "hidden context"
    And I submit a new action with description "another new todo" in the context "hidden context"
    Then I should see "another new todo"

  @javascript
  Scenario Outline: Adding a todo to an empty container hides the empty message 
    Given I have a context called "visible context"
    And I have a project called "visible project"
    And I have selected the view for group by <grouping>
    When I go to the tag page for "test"
    Then I should see empty message for todos of tag
    When I submit a new action with description "a new todo" to project "visible project" with tags "test" in the context "visible context"
    Then I should see "a new todo"
    And I should not see empty message for todos of tag

    Scenarios:
      | grouping |
      | context  |
      | project  |

  @javascript
  Scenario Outline: Adding a dependency to a todo updates the successor
    Given I have a <list_type> "test" with 1 todos
    When I go to the "test" <list_type>
    Then I should see "todo 1"
    When I submit a new action with description "a new todo" with a dependency on "todo 1"
    Then I should not see "a new todo" in the <list_type> container of "test"
    When I expand the dependencies of "todo 1"
    Then I should see "a new todo" within the dependencies of "todo 1"
    And I should not see empty message for deferred todos of <list_type>
    
    Examples:
    | list_type |
    | project   |
    | context   |
    
  @javascript 
  Scenario: Adding a dependency to a todo in another project
    Given I have a project "testing" with 1 todos
    And I have a project "another project"
    When I go to the "another project" project
    And I submit a new action with description "a new todo" with a dependency on "todo 1"
    Then I should not see "a new todo" in the project container of "another project"
    And I should not see empty message for deferred todos of project

  @javascript
  Scenario Outline: I can add multiple todos in a new project and a new context
    Given I have selected the view for group by <grouping>  
    When I go to the home page
    And I follow "Add multiple next actions"
    And I fill the multiple actions form with "", "a next project", "@anywhere", "new tag"
    And I submit the new multiple actions form with
      """

      a
      b
      c


      """
    Then a confirmation for adding a new context "@anywhere" should be asked
    Then I should see "@anywhere"
    And I should see "a"
    And I should see "b"
    And I should see "c"

    Scenarios:
    | grouping  |
    | project   |
    | context   |


  @javascript
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
