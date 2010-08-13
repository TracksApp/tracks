module TracksStepHelper
  def submit_multiple_next_action_form
    selenium.click("xpath=//form[@id='todo-form-multi-new-action']//button[@id='todo_multi_new_action_submit']", :wait_for => :ajax, :javascript_framework => :jquery)
  end

  def submit_next_action_form
    selenium.click("xpath=//form[@id='todo-form-new-action']//button[@id='todo_new_action_submit']", :wait_for => :ajax, :javascript_framework => :jquery)
  end

  def submit_new_context_form
    selenium.click("xpath=//form[@id='context-form']//button[@id='context_new_submit']", :wait_for => :ajax, :javascript_framework => :jquery)
  end

end

World(TracksStepHelper)