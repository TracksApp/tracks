module TracksIdHelper

  def toggle_context_container_xpath(context)
    "//a[@id='toggle_c#{context.id}']"
  end

  def toggle_project_container_xpath(project)
  	"//a[@id='toggle_p#{project.id}']"
  end

  def context_container_xpath(context)
  	"//div[@id='c#{context.id}']"
  end

  def project_container_xpath(project)
	id = project.nil? ? "without_project_container" : "p#{project.id}" 
  	"//div[@id='#{id}']"
  end

  def todo_in_container_xpath(todo, container_type)
  	id = "wrong"
  	id = todo_in_context_container_xpath(todo, todo.context) if container_type == :context
  	id = todo_in_project_container_xpath(todo, todo.project) if container_type == :project
  	return "//div[@id=\"#{id}\"]//div[@id='line_todo_#{todo.id}']"
  end

  def todo_in_context_container_xpath(todo, context)
  	"#{context_container_xpath(context)}//div[@id='line_todo_#{todo.id}']"
  end

  def todo_in_project_container_xpath(todo, project)
  	return "#{project_container_xpath(project)}//div[@id='line_todo_#{todo.id}']"
  end 

  def todo_in_deferred_container_xpath(todo)
  	"//div[@id='deferred_pending_container']//div[@id='line_todo_#{todo.id}']"
  end

end