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

  def wait_for_animations_to_end
    wait_until do
      page.evaluate_script('$(":animated").length') == 0
    end
  end
  
  def wait_for_ajax
    start_time = Time.now
    page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String)
    until(page.evaluate_script('jQuery.isReady&&jQuery.active==0') || (start_time + 5.seconds) < Time.now)
      sleep 0.05
    end
  end

  def wait_for_auto_complete
    page.should have_css("a.ui-state-focus", :visible => true)
  end

  def click_first_line_of_auto_complete
    page.find(:css, "ul li a.ui-state-focus").click
  end

  def check_xpath_visibility(visible, xpath)
    page.send( (visible=="see" ? :should : :should_not), have_xpath(xpath, :visible => true))
  end

  def check_css_visibility(visible, css)
    page.send( (visible=="see" ? :should : :should_not), have_css(css, :visible => true))
  end

  def check_elem_visibility(visible, elem)
    elem.send(visible=="see" ? :should : :should_not, be_visible)
  end

  def find_todo(description)
    todo = @current_user.todos.where(:description => description).first
    todo.should_not be_nil
    return todo
  end

  def find_context(context_name)
    context = @current_user.contexts.where(:name => context_name).first
    context.should_not be_nil
    return context
  end

  def find_project(project_name)
    project = @current_user.projects.where(:name => project_name).first
    project.should_not be_nil
    return project
  end

  def container_list_find_index(container, object)
    div_id = "#{container}_#{object.id}"
    containers = page.all("div.#{container}").map { |x| x[:id] }
    return containers.find_index(div_id)
  end

  def context_list_find_index(context_name)
    return container_list_find_index(:context, find_context(context_name))
  end

  def project_list_find_index(project_name)
    return container_list_find_index(:project, find_project(project_name))
  end
    
  def format_date(date)
    # copy-and-past from ApplicationController::format_date
    return date ? date.in_time_zone(@current_user.prefs.time_zone).strftime("#{@current_user.prefs.date_format}") : ''
  end

  def context_drag_and_drop(drag_id, delta)
    sortable_css = "div.ui-sortable div#container_context_#{drag_id}"
    execute_javascript("$('#{sortable_css}').simulateDragSortable({move: #{delta}, handle: '.grip'});")
  end

  def open_submenu_for(todo)
    submenu_arrow = "div#line_todo_#{todo.id} img.todo-submenu"
    page.should have_css(submenu_arrow, :visible=>true)
    page.find(submenu_arrow, :match => :first).click
    sleep 0.1
    
    submenu_css = "div#line_todo_#{todo.id} ul#ultodo_#{todo.id}"
    submenu = page.find(submenu_css)
    wait_until { submenu.visible? }

    within submenu do
      yield
    end
  end
  
  def handle_js_confirm(accept=true)
    execute_javascript "window.original_confirm_function = window.confirm"
    execute_javascript "window.confirmMsg = null"
    execute_javascript "window.confirm = function(msg) { window.confirmMsg = msg; return #{!!accept}; }"
    yield
  ensure
    execute_javascript "window.confirm = window.original_confirm_function"
  end
  
  def get_confirm_text
    page.evaluate_script "window.confirmMsg"
  end

  def execute_javascript(js)
    page.execute_script(js)
  end
  
end