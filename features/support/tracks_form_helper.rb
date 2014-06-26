module TracksFormHelper

  def open_edit_form_for(todo)
    edit_link = "div#line_todo_#{todo.id} a#icon_edit_todo_#{todo.id}"

    # make sure we can open the edit form
    expect(page).to have_css(edit_link)

    # on calendar page there can be more than 1 occurance of a todo, so we select the first here
    all(:css, edit_link)[0].click
    wait_for_ajax
    wait_for_animations_to_end
  end
  
  def open_context_edit_form(context)
    # open edit form
    page.find("a#link_edit_context_#{context.id}").click

    # wait for the form to appear (which included a submit button)
    expect(page).to have_css("button#submit_context_#{context.id}", :visible=>true)
  end

  def submit_form(form_xpath, button_name)
    handle_js_confirm do
      # on calendar page there can be more than 1 occurance of a todo, so we select the first here
      within all(:xpath, form_xpath)[0] do
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
    expect(page).to_not have_content("button#submit_todo_#{todo.id}")
  end

  def wait_for_context_form_to_appear(context)
    expect(page).to have_css("button#submit_context_#{context.id}", :visible=>true)
  end

  def wait_for_context_form_to_go_away(context)
    # wait for the form to go away
    expect(page).to_not have_css("button#submit_context_#{context.id}", :visible => true)
    # wait for the changed context to appear
    expect(page).to have_css("a#link_edit_context_#{context.id}", :visible=> true)
  end
    
  def open_project_edit_form(project)
    click_link "link_edit_project_#{project.id}"
    expect(page).to have_css("button#submit_project_#{project.id}")
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
    
    expect(page).to_not have_css("button#submit_project_#{project.id}", :visible => true)
  end
  
  def edit_project_settings(project)
    edit_project(project) do
      yield
    end
  end
  
  def clear_context_name_from_next_action_form
    execute_javascript("$('#todo_context_name').val('');")
  end

  def clear_project_name_from_next_action_form
    execute_javascript("$('#todo_project_name').val('');")
  end

end
