Story: Change context name

  As a Tracks user
  I want to change the name of a context
  So that it can best reflect my daily life
  
  Scenario: In place edit of context name
    Given a logged in user Luis
    And Luis has a context Errands
    When Luis visits the Errands context page
    And he edits the Errands context name in place to be OutAndAbout 
    Then he should see the context name is OutAndAbout
    When Luis visits the context listing page
    Then he should see that a context named Errands is not present
    And he should see that a context named OutAndAbout is present
