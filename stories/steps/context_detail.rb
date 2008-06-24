steps_for :context_detail do
  include_steps_for :users
  
  Given "Luis has a context Errands" do
    @errands = @luis.contexts.create!(:name => 'Errands')
  end
  
  When "Luis visits the Errands context page" do
    visits "/contexts/#{@errands.to_param}"
  end
  
  When "he edits the Errands context name in place to be OutAndAbout" do
    selenium.click 'context_name_in_place_editor'
    wait_for_ajax_and_effects
    selenium.type "css=#context_name_in_place_editor-inplaceeditor input.editor_field", "OutAndAbout"
    clicks_button "ok", :wait => :ajax
  end
  
  When "Luis visits the context listing page" do
    visits "/contexts"
  end
  
  Then "he should see the context name is OutAndAbout" do
    should_see 'OutAndAbout'
  end
  
  Then "he should see that a context named Errands is not present" do
    should_not_see 'Errands'
  end
  
  Then "he should see that a context named OutAndAbout is present" do
    should_see 'OutAndAbout'
  end
end
