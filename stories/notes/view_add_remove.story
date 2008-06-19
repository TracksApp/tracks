Story: View, add, remove notes

  As a Tracks user
  I want to view, add, and remove notes
  So that I can keep important information easily accessible
  
  Scenario: View and toggle notes

    Given a logged in user Luis
    And Luis has two projects with one note each
    When Luis visits the notes page
    Then two notes should be visible
    And the badge should show 2
    When Luis clicks Toggle Notes
    Then the body of the notes should be shown    
    
  Scenario: Add a new note

    Given a logged in user Luis
    And Luis has one project Pass Final Exam with no notes
    When Luis adds a note from the Pass Final Exam project page
    Then Luis should see the note on the Pass Final Exam project page
    And Luis should see the note on the notes page
    And the badge on the notes page should show 1
    
  Scenario: Delete note from notes page

    Given a logged in user Luis
    And Luis has one project Pass Final Exam with 2 notes
    When Luis visits the notes page
    And Luis deletes the first note
    Then the first note should disappear
    Then the badge should show 1

  Scenario: Link to note
    Given a logged in user Luis
    And Luis has one project Pass Final Exam with 1 note
    When Luis visits the Pass Final Exam project page
    And clicks the icon next to the note
    Then he should see the note text
  