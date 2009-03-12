class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_api TodoApi
  web_service_scaffold :invoke
  skip_before_filter :login_required
  
  
  def new_todo(username, token, context_id, description, notes)
    check_token(username, token)
    check_context_belongs_to_user(context_id)
    item = create_todo(description, context_id, nil, notes)
    item.id
  end

  def new_todo_for_project(username, token, context_id, project_id, description, notes)
    check_token(username, token)
    check_context_belongs_to_user(context_id)
    item = create_todo(description, context_id, project_id, notes)
    item.id
  end
  
  def new_rich_todo(username, token, default_context_id, description, notes)
    check_token(username,token)
    item = Todo.from_rich_message(@user, default_context_id, description, notes)
    item.save
    raise item.errors.full_messages.to_s if item.new_record?
    item.id
  end
  
  def list_contexts(username, token)
    check_token(username, token)
    
    @user.contexts
  end
  
  def list_projects(username, token)
    check_token(username, token)
    
    @user.projects
  end
  
  private

  # Check whether the token in the URL matches the token in the User's table
  def check_token(username, token)
    @user = User.find_by_login( username )
    unless (token == @user.token)
      raise(InvalidToken, "Sorry, you don't have permission to perform this action.")
    end
  end
    
  def check_context_belongs_to_user(context_id)
    unless @user.contexts.exists? context_id
      raise(CannotAccessContext, "Cannot access a context that does not belong to this user.")
    end
  end
    
  def create_todo(description, context_id, project_id = nil, notes="")
    item = @user.todos.build
    item.description = description
    item.notes = notes
    item.context_id = context_id
    item.project_id = project_id unless project_id.nil?
    item.save
    raise item.errors.full_messages.to_s if item.new_record?
    item
  end
end

class InvalidToken < RuntimeError; end
