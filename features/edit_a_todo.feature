Feature: Edit a next action from every page
  In order to manage a next action
  As a Tracks user
  I want to to be able to change the next action from every page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@pc"

  @javascript
  Scenario: I can toggle the star of a todo
    Given I have a todo "star me" in the context "@home"
    When I go to the home page
    And I star the action "star me"
    Then I should see a starred "star me"
    When I go to the tag page for "starred"
    Then I should see "star me"

  @javascript
  Scenario Outline: I can delete a todo
    Given I have a todo "delete me" in the context "@home"
    And I have selected the view for group by <grouping>
    When I go to the home page
    Then I should see "delete me"
    When I delete the action "delete me"
    Then I should not see "delete me"

    Scenarios:
      | grouping |
      | context  |
      | project  |

  @javascript 
  Scenario Outline: Removing the last todo in container will hide that container
    Given I have a todo "delete me" in the context "@home" in the project "do it!"
    And I have selected the view for group by <grouping>
    When I go to the home page
    Then I should see the <container> 
    And I should see "delete me" in the <container> 
    When I mark "delete me" as complete
    Then I should not see the <container>
    And I should see "delete me" in the completed container
    When I mark "delete me" as uncompleted
    Then I should see the <container>
    And I should see "delete me" in the <container>

    Scenarios:
      | grouping | container                      |
      | context  | container for context "@home"  |
      | project  | container for project "do it!" |

  @javascript
  Scenario Outline: Changing container of the todo in that container will hide it
    Given I have a todo "delete me" in the context "@home" in the project "do it"
    And I have a project "go for it"
    And I have selected the view for group by <grouping>
    When I go to the home page
    And I edit the <grouping> of "delete me" to <new_grouping>
    Then I should not see the <container>
    And I should see the <new_container>
    And I should see "delete me" in the <new_container>
    When I delete the todo "delete me"
    Then I should not see the todo "delete me"
    And I should not see the <container>
    And I should not see the <new_container>

    Scenarios:
      | grouping | container                      | new_grouping | new_container                      |
      | context  | container for context "@home"  | "@pc"        | container for context "@pc"        |
      | project  | container for project "do it"  | "go for it"  | container for project "go for it"  |

  @javascript
  Scenario Outline: Deleting the last todo in container will show empty message # only project, context, tag, not todo
    Given I have a context called "@home"
    And I have selected the view for group by <grouping>
    And I have a project "my project" that has the following todos
      | context | description   | tags      |
      | @home   | first action  | test, bla |
      | @home   | second action | bla       |
    When I go to the <page>
    Then I should not see empty message for todos of <page type>
    And I should see "first action"
    When I delete the todo "first action"
    Then I should not see empty message for todos of <page type>
    When I delete the todo "second action"
    Then I should see empty message for todos of <page type>

    Scenarios:
      | page                     | page type      | grouping |
      | "my project" project     | project        | project  |
      | "my project" project     | project        | context  |
      | context page for "@home" | context        | context  |
      | context page for "@home" | context        | project  |
      | tag page for "bla"       | tag            | context  |
      | tag page for "bla"       | tag            | project  |

  @javascript 
  Scenario Outline: I can mark an active todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page>
    Then I should see empty message for todos of <page type>
    When I submit a new action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see empty message for todos of <page type>
    When I mark "visible todo" as complete
    And I should see empty message for todos of <page type>
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                               | page type |
      | home page                          | home      |
      | "visible project" project          | project   |
      | tag page for "starred"             | tag       |
      | context page for "visible context" | context   |

  @javascript
  Scenario Outline: I can mark a deferred todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page>
    Then I should see empty message for deferred todos of <page type>
    When I submit a new deferred action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see empty message for deferred todos of <page type>
    When I mark "visible todo" as complete
    And I should see empty message for deferred todos of <page type>
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                               | page type  |
      | tag page for "starred"             | tag        |
      | "visible project" project          | project    |
      | context page for "visible context" | context    |

  @javascript 
  Scenario Outline: I can mark a completed todo active and it will update empty messages and context containers
    Given I have a completed todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context"
    And I have selected the view for group by <grouping>
    When I go to the <page>
    Then I should see empty message for todos of <page type>
    And I should not see the <container>
    And I should not see empty message for completed todos of <page type>
    When I mark the completed todo "visible todo" active
    Then I should see the <container>
    And I should see empty message for completed todos of <page type>
    And I should see "visible todo" in the <container>
    And I should not see empty message for todos of <page type>

    Scenarios:
      | page                   | page type                | grouping | container                               |
      | tag page for "starred" | tag                      | context  | container for context "visible context" |
      | tag page for "starred" | tag                      | project  | container for project "visible project" |
      | home page              | home                     | context  | container for context "visible context" |
      | home page              | home                     | project  | container for project "visible project" |

  @javascript 
  Scenario Outline: I can mark a completed todo active and it will update empty messages for pages without hideable containers
    Given I have a completed todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context"
    When I go to the <page>
    Then I should see empty message for todos of <page type>
    And I should not see empty message for completed todos of <page type>
    When I mark the completed todo "visible todo" active
    And I should see empty message for completed todos of <page type>
    And I should not see empty message for todos of <page type>

    Scenarios:
      | page                               | page type  |
      | context page for "visible context" | context    |
      | "visible project" project          | project    |

  @javascript
  Scenario Outline: I can edit a todo to change its description
    Given I have a todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context" that is due next week
    And I have selected the view for group by <grouping>
    When I go to the <page>
    And I edit the description of "visible todo" to "changed todo"
    Then I should not see the todo "visible todo"
    And I should see the todo "changed todo"

    Scenarios:
      | page                               | grouping |
      | home page                          | context  |
      | home page                          | project  |
      | context page for "visible context" | context  |
      | "visible project" project          | context  |
      | tag page for "starred"             | context  |
      | tag page for "starred"             | project  |
      | calendar page                      | context  |

  @javascript
  Scenario Outline: I can edit a todo to move it to another container
    Given I have a context called "@laptop"
    And I have selected the view for group by <grouping>
    And I have a project "project 1" that has the following todos
      | context | description   | tags |
      | @pc     | first action  | bla  |
      | @laptop | second action | bla  |
    And I have a project "project 2"
    When I go to the <page>
    Then I should see "first action" in the <container>
    When I edit the <grouping> of "first action" to <new grouping>
    Then I should not see "first action" in the <container>
    Then I should see "first action" in the <new container>

    Scenarios:
    | page               | grouping | container                         | new grouping  | new container                     |
    | home page          | context  | context container for "@pc"       | "@laptop"     | context container for "@laptop"   |
    | home page          | project  | project container for "project 1" | "project 2"   | project container for "project 2" |
    | tag page for "bla" | context  | context container for "@pc"       | "@laptop"     | context container for "@laptop"   |
    | tag page for "bla" | project  | project container for "project 1" | "project 2"   | project container for "project 2" |

  @javascript
  Scenario: I can edit a todo to move it to another context in tickler page
    Given I have a context called "@laptop"
    And I have a project "my project" that has the following deferred todos
      | context | description   |
      | @pc     | first action  |
      | @laptop | second action |
    When I go to the tickler page
    Then I should see "first action" in the context container for "@pc"
    When I edit the context of "first action" to "@laptop"
    Then I should not see "first action" in the context container for "@pc"
    Then I should see "first action" in the context container for "@laptop"

  @javascript
  Scenario: I can edit a todo to move it to another project
    Given I have a project called "project one"
    And I have a project "project two" with 1 todos
    When I go to the "project two" project
    And I edit the project of "todo 1" to "project one"
    Then I should not see the todo "todo 1"
    When I go to the "project one" project
    Then I should see the todo "todo 1"

  @javascript
  Scenario: I can give a todo without a project a blank project name
    Given I have a todo "todo 1" in the context "@pc"
    When I go to the home page
    And I edit the project of "todo 1" to ""
    Then I should see the todo "todo 1"

  @javascript
  Scenario: I can edit a todo without a project and the project remains blank
    Given I have a todo "todo 1"
    When I go to the home page
    And I change the todo[description] field of "todo 1" to "todo 1 edit"
    Then I should see the todo "todo 1 edit" with project name ""

  @javascript
  Scenario: I can edit a todo to move it to the tickler
    When I go to the home page
    And I submit a new action with description "start later" in the context "@pc"
    And I edit the show from date of "start later" to next month
    Then I should not see the todo "start later"
    When I go to the tickler page
    Then I should see the todo "start later"

  @javascript
  Scenario: I can defer a todo
    When I go to the home page
    And I submit a new action with description "start later" in the context "@pc"
    When I go to the home page
    And I defer "start later" for 1 day
    Then I should not see "start later"
    When I go to the tickler page
    Then I should see "start later"

  @javascript
  Scenario: I can make a project from a todo
    When I go to the home page
    And I submit a new action with description "buy mediacenter" in the context "@pc"
    When I go to the home page
    And I make a project of "buy mediacenter"
    #sidebar does not update
    Then I should be on the "buy mediacenter" project
    When I go to the projects page
    Then I should see "buy mediacenter"

  @javascript
  Scenario: I can show the notes of a todo
    Given I have a todo "read the notes" with notes "several things to read"
    When I go to the home page
    Then I should see "read the notes"
    And I should not see the notes of "read the notes"
    When I open the notes of "read the notes"
    Then I should see the notes of "read the notes"

  @javascript
  Scenario: I can tag a todo
    Given I have a todo "tag me"
    When I go to the home page
    And I edit the tags of "tag me" to "bla, bli"
    Then I should see the todo "bla"
    And I should see the todo "bli"

  Scenario: Clicking a tag of a todo will go to that tag page
    Given I have a todo "tag you are it" in context "@tags" with tags "taga, tagb"
    When I go to the home page
    Then I should see "tag you are it"
    And I should see "taga"
    When I follow "taga"
    Then I should be on the tag page for "taga"

  @javascript
  Scenario: I can edit the tags of a todo
    Given I have a todo "tag you are it" in context "@tags" with tags "taga, tagb"
    When I go to the home page
    Then I should see "tag you are it"
    When I edit the tags of "tag you are it" to "tagb, tagc"
    Then I should not see "taga"
    And I should see "tagb"
    And I should see "tagc"

  @javascript
  Scenario Outline: Editing the container of a todo to a new container will show new container
    Given I have a todo "moving" in context "@pc" in project "project 1 " with tags "tag"
    And I have selected the view for group by <grouping>
    When I go to the <page>
    And I edit the <grouping> of "moving" to <new grouping>
    And I should see the <container>

    Scenarios:
    | page                | grouping | new grouping | container                         |
    | home page           | context  | "@new"       | container for context "@new"      |
    | home page           | project  | "project 2"  | container for project "project 2" |
    | tag page for "tag"  | context  | "@new"       | container for context "@new"      |
    | tag page for "tag"  | project  | "project 2"  | container for project "project 2" |

  @javascript
  Scenario: Editing the context of a todo in the tickler to a new context will show new context
    Given I have a deferred todo "moving" in context "@pc" with tags "tag"
    When I go to the tickler page
    And I edit the context of "moving" to "@new"
    Then I should see the container for context "@new"

  @javascript
  Scenario: Editing the context of a todo in the project view to a new context will show new context
    Given I have a todo "something" in the context "@pc" in the project "project"
    When I go to the "project" project page
    And I edit the context of "something" to "@new"
    Then I should see the container for context "@new"

  @javascript
  Scenario: Making an error when editing a todo will show error message
    Given I have a todo "test"
    When I go to the home page
    And I try to edit the description of "test" to ""
    Then I should see an error message
