steps_for :notes do
  include_steps_for :users

  Given "Luis has two projects with one note each" do
    project_a = @luis.projects.create!(:name => 'project A')
    project_a.notes.create!(:user_id => @luis.id, :body => 'note for project A')
    project_b = @luis.projects.create!(:name => 'project B')
    project_b.notes.create!(:user_id => @luis.id, :body => 'note for project B')
  end
  
  Given "Luis has one project Pass Final Exam with no notes" do
    @exam_project = @luis.projects.create!(:name => 'Pass Final Exam')
  end

  Given "Luis has one project Pass Final Exam with 1 note" do
    Given "Luis has one project Pass Final Exam with no notes"
    @exam_project.notes.create!(:user_id => @luis.id, :body => 'exam note 1')
  end
  
  Given "Luis has one project Pass Final Exam with 2 notes" do
    Given "Luis has one project Pass Final Exam with 1 note"
    @exam_project.notes.create!(:user_id => @luis.id, :body => 'exam note 2')
  end
  
  When "Luis visits the notes page" do
    visits '/notes'
  end
  
  When "Luis adds a note from the Pass Final Exam project page" do
    When "Luis visits the Pass Final Exam project page"
    clicks_link 'Add a note', :wait => :ajax
    fills_in 'new_note_body', :with => 'new exam note'
    clicks_button 'Add note', :wait => :ajax
  end
  
  When "Luis visits the Pass Final Exam project page" do
    visits "/projects/#{@exam_project.to_param}"
  end
  
  When "Luis deletes the first note" do
    selenium.click "css=a.delete_note"
    selenium.get_confirmation.should =~ /delete/
  end
  
  When "clicks the icon next to the note" do
    selenium.click "css=a.link_to_notes"
    wait_for_page_to_load
  end
  
  When "Luis clicks Toggle Notes" do
    clicks_link 'Toggle notes', :wait => :effects
  end
  
  Then "the body of the notes should be shown" do
    wait_for_effects
    selenium.is_visible("css=body.notes").should be_true    
  end
    
  Then "Luis should see the note on the Pass Final Exam project page" do
    should_see "new exam note"
  end
  
  Then "Luis should see the note on the notes page" do
    visits '/notes'
    should_see "new exam note"
  end
  
  Then "the badge on the notes page should show 1" do
    badge_count_should_show(1)
  end
  
  Then "the first note should disappear" do
    wait_for_ajax_and_effects
    should_not_see 'exam note 1'
  end
  
  Then "the badge should show 1" do
    wait_for_ajax_and_effects
    badge_count_should_show(1)
  end

  Then "the badge should show 2" do
    badge_count_should_show(2)
  end
    
  Then "two notes should be visible" do
    should_see 'note for project A'
    should_see 'note for project B'    
  end
  
  Then "he should see the note text" do
    should_see 'exam note 1'
  end
end