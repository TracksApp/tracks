Feature: Show done
  In order to see what I have completed
  As an user
  I want to see my done todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@pc"
    And I have a project called "test project"
    And I have 1 completed todos in project "test project" in context "@pc" with tags "starred"

  Scenario: Visit done overview page
    When I go to the done page
    Then I should see "Last Completed Actions"
    And I should see "Last Completed Projects"
    And I should see "Last Completed Recurring Actions"

  Scenario Outline: Page with actions links to show all completed actions
    When I go to the <page>
    Then I should see "Completed actions"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the <next page>

    Scenarios:
    | page                    | next page                                    |
    | home page               | done actions page                            |
    | context page for "@pc"  | done actions page for context "@pc"          |
    | "test project" project  | done actions page for project "test project" |
    | tag page for "starred"  | done actions page for tag "starred"          |

  Scenario Outline: I can see all todos completed in the last timeperiod
    When I go to the <page>
    Then I should see "todo 1"
    And I should see "Completed today"
    And I should see "Completed in the rest of this week"
    And I should see "Completed in the rest of this month"

    Scenarios:
    | page                                         |
    | done actions page                            |
    | done actions page for context "@pc"          |
    | done actions page for project "test project" |
    | done actions page for tag "starred"          |

  Scenario Outline: I can see all todos completed
    When I go to the <page>
    And I should see "You can see all completed actions here"
    When I follow "here"
    Then I should be on the <other page>

    Scenarios:
    | page                                         | other page                                       |
    | done actions page                            | all done actions page                            |
    | done actions page for project "test project" | all done actions page for project "test project" |
    | done actions page for context "@pc"          | all done actions page for context "@pc"          |
    | done actions page for tag "starred"          | all done actions page for tag "starred"          |

  Scenario Outline: I can browse all todos completed by page
    Given I have 50 completed todos with a note in project "test project" in context "@pc" with tags "starred"
    When I go to the <page>
    Then I should see the page selector
    When I select the second page
    Then I should be on the <page>
    And the page should be "2"

    Scenarios:
    | page                                             |
    | all done actions page                            |
    | all done actions page for project "test project" |
    | all done actions page for context "@pc"          |
    | all done actions page for tag "starred"          |

  Scenario: The projects page shows a link to all completed projects
    Given I have a completed project called "finished"
    When I go to the projects page
    Then I should see "finished"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the done projects page
    And I should see "finished"

  Scenario: I can browse all completed projects by page
    Given I have 40 completed projects
    When I go to the projects page
    Then I should see "10 / 40"
    When I follow "Show all"
    Then I should see the page selector
    And I should see "40 (1-20)"
    When I select the second page
    Then I should be on the done projects page
    And the page should be "2"

  Scenario: The recurring todos page shows a link to all completed recurring todos
    Given I have a completed recurrence pattern "finished"
    When I go to the recurring todos page
    Then I should see "finished"
    And I should see "Show all"
    When I follow "Show all"
    Then I should be on the done recurring todos page
    And I should see "finished"

  Scenario: I can browse all completed recurring todos by page
    Given I have 40 completed recurrence patterns
    When I go to the recurring todos page
    And I follow "Show all"
    Then I should see the page selector
    And I should see "40 (1-20)"
    When I select the second page
    Then I should be on the done recurring todos page
    And the page should be "2"

  @javascript
  Scenario: I can toggle a done recurring todo active from done page
    Given I have a completed recurrence pattern "test pattern"
    When I go to the done recurring todos page
    Then I should see "test pattern"
    When I mark the pattern "test pattern" as active
    Then I should not see "test pattern" in the completed recurring todos container
    When I go to the recurring todos page
    Then I should see "test pattern" in the active recurring todos container

  @javascript
  Scenario: I can delete a recurring todo from the done page
    Given I have a completed recurrence pattern "test pattern"
    When I go to the done recurring todos page
    Then I should see "test pattern"
    When I delete the pattern "test pattern"
    Then I should not see "test pattern" in the completed recurring todos container
    When I go to the recurring todos page
    Then I should not see "test pattern" in the active recurring todos container

  @javascript
  Scenario Outline: I can toggle a todo active from the done pages
    When I go to the <page>
    Then I should see the todo "todo 1"
    When I mark the completed todo "todo 1" active
    Then I should not see the todo "todo 1"
    When I go to the <next page>
    Then I should see "todo 1" <where>

    Scenarios:
    | page                                            | next page               | where                               |
    | done actions page                               | home page               | in the context container for "@pc"  |
    | all done actions page                           | home page               | in the context container for "@pc"  |
    | done actions page for context "@pc"             | context page for "@pc"  |                                     |
    | done actions page for project "test project"    | "test project" project  |                                     |
    | done actions page for tag "starred"             | home page               | in the context container for "@pc"  |
    | all done actions page for context "@pc"         | context page for "@pc"  |                                     |
    | all done actions page for project "test project"| "test project" project  |                                     |
    | all done actions page for tag "starred"         | home page               | in the context container for "@pc"  |

  @javascript
  Scenario: Activating the last todo will show empty message
    When I go to the done actions page
    Then I should see "todo 1" in the done today container
    When I mark the completed todo "todo 1" active
    Then I should not see the todo "todo 1"
    And I should see empty message for done today of done actions

  @javascript
  Scenario Outline: I can toggle the star of a todo from the done pages
    When I go to the <page>
    Then I should see a starred "todo 1"
    When I unstar the action "todo 1"
    Then I should see an unstarred "todo 1"

    Scenarios:
    | page                                            |
    | done actions page                               |
    | all done actions page                           |
    | done actions page for context "@pc"             |
    | done actions page for project "test project"    |
    | done actions page for tag "starred"             |
    | all done actions page for context "@pc"         |
    | all done actions page for project "test project"|
    | all done actions page for tag "starred"         |

  @javascript
  Scenario: I can edit a project to active from the project done page
    Given I have a completed project called "completed project"
    When I go to the done projects page
    Then I should see "completed project"
    When I edit the project state of "completed project" to "active"
    Then I should not see the project "completed project"
    When I go to the projects page
    Then I should see "completed project"

  Scenario Outline: All pages are internationalized
    Given I set the locale to "<locale>"
    When I go to the <page>
    Then I should not see "translation missing"

    Scenarios:
    | page                                            | locale  |
    | done actions page                               | en      |
    | all done actions page                           | en      |
    | done actions page for context "@pc"             | en      |
    | done actions page for project "test project"    | en      |
    | done actions page for tag "starred"             | en      |
    | all done actions page for context "@pc"         | en      |
    | all done actions page for project "test project"| en      |
    | all done actions page for tag "starred"         | en      |
    | done actions page                               | nl      |
    | all done actions page                           | nl      |
    | done actions page for context "@pc"             | nl      |
    | done actions page for project "test project"    | nl      |
    | done actions page for tag "starred"             | nl      |
    | all done actions page for context "@pc"         | nl      |
    | all done actions page for project "test project"| nl      |
    | all done actions page for tag "starred"         | nl      |
    | done actions page                               | de      |
    | all done actions page                           | de      |
    | done actions page for context "@pc"             | de      |
    | done actions page for project "test project"    | de      |
    | done actions page for tag "starred"             | de      |
    | all done actions page for context "@pc"         | de      |
    | all done actions page for project "test project"| de      |
    | all done actions page for tag "starred"         | de      |
    | done actions page                               | es      |
    | all done actions page                           | es      |
    | done actions page for context "@pc"             | es      |
    | done actions page for project "test project"    | es      |
    | done actions page for tag "starred"             | es      |
    | all done actions page for context "@pc"         | es      |
    | all done actions page for project "test project"| es      |
    | all done actions page for tag "starred"         | es      |
    | done actions page                               | fr      |
    | all done actions page                           | fr      |
    | done actions page for context "@pc"             | fr      |
    | done actions page for project "test project"    | fr      |
    | done actions page for tag "starred"             | fr      |
    | all done actions page for context "@pc"         | fr      |
    | all done actions page for project "test project"| fr      |
    | all done actions page for tag "starred"         | fr      |
    | done actions page                               | cs      |
    | all done actions page                           | cs      |
    | done actions page for context "@pc"             | cs      |
    | done actions page for project "test project"    | cs      |
    | done actions page for tag "starred"             | cs      |
    | all done actions page for context "@pc"         | cs      |
    | all done actions page for project "test project"| cs      |
    | all done actions page for tag "starred"         | cs      |
