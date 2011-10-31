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

  @selenium
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

  @selenium
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

  @selenium
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

  @selenium
  Scenario Outline: I can add a todo from several pages
    When I go to the <page>
    And I submit a new action with description "a new next action"
    Then I should <see> "a new next action"

    Scenarios:
      | page                            | see     |
      | home page                       | see     |
      | tickler page                    | not see |
      | "test project" project          | see     |
      | context page for "test context" | see     |
      | tag page for "starred"          | see     |

  @selenium
  Scenario Outline: I can add multiple todos from several pages
    When I go to the <page>
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
      | page                            | see     | badge | count |
      | home page                       | see     | 3     | 3     |
      | tickler page                    | not see | 0     | 3     |
      | "test project" project          | see     | 3     | 3     |
      | context page for "test context" | see     | 2     | 3     |
      | tag page for "starred"          | not see | 0     | 3     |

  @selenium
  Scenario: Adding a todo to another project does not show the todo
    Given I have a project called "another project"
    When I go to the "test project" project
    And I submit a new action with description "can you see me?" to project "another project" in the context "test context"
    Then I should not see "can you see me?"
    When I go to the "another project" project
    Then I should see "can you see me?"

  @selenium
  Scenario: Adding a deferred todo to another project does not show the todo
    # scenario for #1146
    Given I have a project called "another project"
    When I go to the "test project" project
    And I submit a deferred new action with description "a new next action" to project "another project" in the context "test context"
    Then I should not see "a new next action"
    And I submit a deferred new action with description "another new next action" to project "test project" in the context "test context"
    Then I should see "another new next action"

  @selenium
  Scenario Outline: Adding a todo with a new context shows the new context
    When I go to the <page>
    And I submit a new <todo> with description "do at new context" and the tags "starred" in the context "New"
    Then a confirmation for adding a new context "New" should be asked
    And the container for the context "New" should <visible>
    And the badge should show <badge>

    Scenarios:
      | page                            | todo            | badge | visible        |
      | home page                       | action          | 2     | be visible     |
      | tickler page                    | deferred action | 1     | be visible     |
      | "test project" project          | action          | 2     | not be visible |
      | context page for "test context" | action          | 1     | not be visible |
      | tag page for "starred"          | action          | 1     | be visible     |

  @selenium
  Scenario Outline: Adding a todo to a hidden project does not show the todo
    Given I have a hidden project called "hidden project"
    And I have a project called "visible project"
    And I have a context called "visible context"
    And I have a context called "other context"
    When I go to the <page>
    And I submit a new action with description "hidden todo" to project "hidden project" with tags "test" in the context "visible context"
    Then I should <see_hidden> "hidden todo"
    When I submit a new action with description "visible todo" to project "visible project" with tags "test" in the context "visible context"
    Then I should <see_visible> "visible todo"

    Scenarios:
      | page                               | see_hidden | see_visible |
      | home page                          | not see    | see         |
      | tickler page                       | not see    | not see     |
      | "visible project" project          | not see    | see         |
      | "hidden project" project           | see        | not see     |
      | context page for "visible context" | not see    | see         |
      | context page for "other context"   | not see    | not see     |
      | tag page for "starred"             | not see    | not see     |
      | tag page for "test"                | see        | see         |

  @selenium
  Scenario: Adding a todo to a hidden context from home page does not show the todo
    Given I have a context called "visible context"
    And I have a hidden context called "hidden context"
    When I go to the home page
    And I submit a new action with description "a new todo" in the context "visible context"
    Then I should see "a new todo"
    When I submit a new action with description "another new todo" in the context "hidden context"
    Then I should not see "another new todo"

  @selenium
  Scenario: Adding a todo to a context show the todo in that context page
    Given I have a context called "visible context"
    And I have a hidden context called "hidden context"
    When I go to the context page for "visible context"
    And I submit a new action with description "a new todo" in the context "visible context"
    Then I should see "a new todo"
    When I go to the context page for "hidden context"
    And I submit a new action with description "another new todo" in the context "hidden context"
    Then I should see "another new todo"

  @selenium
  Scenario: Adding a todo to an empty container hides the empty message # TODO: make outline
    Given I have a context called "visible context"
    When I go to the tag page for "test"
    Then I should see "Currently there are no incomplete actions with the tag 'test'"
    When I submit a new action with description "a new todo" and the tags "test" in the context "visible context"
    Then I should see "a new todo"
    And I should not see "Currently there are no incomplete actions with the tag 'bla'"

  @selenium
  Scenario: Adding a dependency to a todo updated the successor
    When I go to the "test project" project
    Then I should see "todo 1"
    When I submit a new action with description "a new todo" with a dependency on "todo 1"
    Then I should not see "a new todo" in the project container of "test project"
    When I expand the dependencies of "todo 1"
    Then I should see "a new todo" within the dependencies of "todo 1"

  @selenium
  Scenario: I can add multiple todos in a new project and a new context
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
