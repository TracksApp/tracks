module TracksStepHelper

  def wait_until(timeout = 5)
    timeout(timeout) { yield }
  end

  def timeout(seconds = 1, error_message = nil, &block)
    start_time = Time.now

    result = nil

    until result
     return result if result = yield

     delay = seconds - (Time.now - start_time)
     if delay <= 0
       raise TimeoutError, error_message || "timed out"
     end

     sleep(0.05)
    end
  end

  def open_edit_form_for(todo)
    edit_link = "div#line_todo_#{todo.id} a#icon_edit_todo_#{todo.id}"

    # make sure we can open the edit form
    page.should have_css(edit_link)

    # on calendar page there can be more than 1 occurance of a todo, so we select the first here
    all(:css, edit_link)[0].click
    wait_for_ajax
    wait_for_animations_to_end
  end
  
  def submit_form(form_xpath, button_name)
    handle_js_confirm do
      within(:xpath, form_xpath) do
        click_button(button_name)
      end
      wait_for_ajax
      wait_for_animations_to_end
    end
  end
  
  def submit_multiple_next_action_form
    submit_form("//form[@id='todo-form-multi-new-action']", "todo_multi_new_action_submit")
  end

  def submit_next_action_form
    submit_form("//form[@id='todo-form-new-action']", "todo_new_action_submit")
  end

  def submit_new_context_form
    submit_form("//form[@id='context-form']", "context_new_submit")
  end

  def submit_new_project_form
    submit_form("//form[@id='project_form']", "project_new_project_submit")
  end
  
  def submit_edit_todo_form (todo)
    submit_form("//div[@id='edit_todo_#{todo.id}']", "submit_todo_#{todo.id}")
    wait_for_todo_form_to_go_away(todo)
  end
  
  def wait_for_todo_form_to_go_away(todo)
    page.should_not have_content("button#submit_todo_#{todo.id}")
  end
    
  def open_project_edit_form(project)
    click_link "link_edit_project_#{project.id}"
    page.should have_css("button#submit_project_#{project.id}")
  end
  
  def submit_project_edit_form(project)
    page.find("button#submit_project_#{project.id}").click
  end
  
  def edit_project_no_wait(project)
    open_project_edit_form(project)
    yield
    submit_project_edit_form(project)
  end
  
  def edit_project(project)
    open_project_edit_form(project)
    within "form#edit_form_project_#{project.id}" do
      yield
    end
    submit_project_edit_form(project)
    
    wait_for_ajax
    wait_for_animations_to_end
    
    page.should_not have_css("button#submit_project_#{project.id}", :visible => true)
  end
  
  def edit_project_settings(project)
    edit_project(project) do
      yield
    end
  end
  
  def open_submenu_for(todo)
    submenu_arrow = "div#line_todo_#{todo.id} img.todo-submenu"
    page.should have_css(submenu_arrow, :visible=>true)
    
    page.find(submenu_arrow).click
    
    page.should have_css("div#line_todo_#{todo.id} ul#ultodo_#{todo.id}", :visible => true)
  end

  def context_list_find_index(context_name)
    div_id = "context_#{@current_user.contexts.find_by_name(context_name).id}"
    contexts = page.all("div.context").map { |x| x[:id] }
    return contexts.find_index(div_id)
  end

  def project_list_find_index(project_name)
    # TODO: refactor with context_list_find_index
    div_id = "project_#{@current_user.projects.find_by_name(project_name).id}"
    project = page.all("div.project").map { |x| x[:id] }
    return project.find_index(div_id)
  end
    
  def wait_for_animations_to_end
    wait_until do
      page.evaluate_script('$(":animated").length') == 0
    end
  end
  
  def wait_for_ajax
    start_time = Time.now
    page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String)
    until(page.evaluate_script('jQuery.isReady&&jQuery.active==0') || (start_time + 5.seconds) < Time.now)
      sleep 0.25
    end
  end

  def format_date(date)
    # copy-and-past from ApplicationController::format_date
    return date ? date.in_time_zone(@current_user.prefs.time_zone).strftime("#{@current_user.prefs.date_format}") : ''
  end

  def execute_javascript(js)
    page.execute_script(js)
  end

  def clear_context_name_from_next_action_form
    execute_javascript("$('#todo_context_name').val('');")
  end

  def clear_project_name_from_next_action_form
    execute_javascript("$('#todo_project_name').val('');")
  end
  
  def handle_js_confirm(accept=true)
    page.execute_script "window.original_confirm_function = window.confirm"
    page.execute_script "window.confirmMsg = null"
    page.execute_script "window.confirm = function(msg) { window.confirmMsg = msg; return #{!!accept}; }"
    yield
  ensure
    page.execute_script "window.confirm = window.original_confirm_function"
  end
  
  def get_confirm_text
    page.evaluate_script "window.confirmMsg"
  end
  
end

World(TracksStepHelper)