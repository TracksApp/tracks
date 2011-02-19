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

  def submit_new_project_form
    selenium.click("xpath=//form[@id='project_form']//button[@id='project_new_project_submit']", :wait_for => :ajax, :javascript_framework => :jquery)
  end

  def submit_edit_todo_form (todo)
    selenium.click("//div[@id='edit_todo_#{todo.id}']//button[@id='submit_todo_#{todo.id}']", :wait_for => :ajax, :javascript_framework => :jquery)
  end
  
  def format_date(date)
    # copy-and-past from ApplicationController::format_date
    return date ? date.in_time_zone(@current_user.prefs.time_zone).strftime("#{@current_user.prefs.date_format}") : ''
  end

  def execute_javascript(js)
    selenium.get_eval "(function() {with(this) {#{js}}}).call(selenium.browserbot.getCurrentWindow());"
  end

  def clear_context_name_from_next_action_form
    execute_javascript("$('#todo_context_name').val('');")
  end

  def clear_project_name_from_next_action_form
    execute_javascript("$('#todo_project_name').val('');")
  end

end

World(TracksStepHelper)