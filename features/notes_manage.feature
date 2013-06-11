Feature: View, add, remove notes
  In order to manage my notes
  As a Tracks user
  I want to view, add, and remove notes

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  Scenario: View notes
    Given I have two projects with one note each
    When I go to the notes page
    Then 2 notes should be visible
    And the badge should show 2

  Scenario: Add a new note
    Given I have one project "Pass Final Exam" with no notes
    When I add note "My Note A" from the "Pass Final Exam" project page
    Then I should see note "My Note A" on the "Pass Final Exam" project page
    And I should see note "My Note A" on the notes page
    Then the badge should show 1

  Scenario: Link to note
    Given I have a project "Pass Final Exam" with 1 note
    When I go to the "Pass Final Exam" project
    And I click the icon next to the note
    Then I should see the note text

  @javascript
  Scenario: Delete note from notes page
    Given I have a project "Pass Final Exam" with 2 notes
    When I go to the notes page
    And I delete the first note
    Then the badge should show 1

  @javascript 
  Scenario: Edit a note
    Given I have a project "Pass Final Exam" with 2 notes
    When I go to the notes page
    And I edit the first note to "edited note"
    Then I should see "edited note"

  @javascript
  Scenario: Toggle all notes
    Given I have a context called "@pc"
    And I have a project "take notes" that has the following todos
      | description | context | notes  |
      | test 1      | @pc     | note A |
      | test 2      | @pc     | note B |
      | test 3      | @pc     | note C |
    When I go to the home page
    Then I should not see the note "note A"
    And I should not see the note "note B"
    And I should not see the note "note C"
    When I toggle the note of "test 1"
    Then I should see the note "note A"
    And I should not see the note "note B"
    And I should not see the note "note C"
    When I toggle the note of "test 1"
    Then I should not see the note "note A"
    When I toggle all notes
    Then I should see the note "note A"
    And I should see the note "note B"
    And I should see the note "note C"
