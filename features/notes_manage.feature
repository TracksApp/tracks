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
    When I visit the "Pass Final Exam" project
    And I click the icon next to the note
    Then I should see the note text

  @selenium
  Scenario: Delete note from notes page
    Given I have a project "Pass Final Exam" with 2 notes
    When I go to the notes page
    And I delete the first note
    Then the first note should disappear
    And the badge should show 1

  @selenium
  Scenario: Edit a note
    Given I have a project "Pass Final Exam" with 2 notes
    When I go to the notes page
    And I edit the first note to "edited note"
    Then I should see "edited note"
