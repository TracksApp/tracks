class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_api TodoApi
  web_service_scaffold :invoke
  skip_before_filter :login_required
  
  
  def new_todo(username, token, context_id, description)
    check_token_against_user_word(username, token)
    check_context_belongs_to_user(context_id)
    item = create_todo(description, context_id)
    item.id
  end
  
  def new_rich_todo(username, token, default_context_id, description)
    check_token_against_user_word(username,token)
    description,context = split_by_char('@',description)
    description,project = split_by_char('>',description)
    if(!context.nil? && project.nil?)
      context,project = split_by_char('>',context)
    end

    context_id = default_context_id
    unless(context.nil?)
      found_context = @user.contexts.find_by_namepart(context)
      context_id = found_context.id unless found_context.nil?
    end
    check_context_belongs_to_user(context_id)
    
    project_id = nil
    unless(project.blank?)
      if(project[0..3].downcase == "new:")
        found_project = @user.projects.build
        found_project.name = project[4..255+4].strip
        found_project.save!
      else
        found_project = @user.projects.find_by_namepart(project)
      end
      project_id = found_project.id unless found_project.nil?
    end

    todo = create_todo(description, context_id, project_id)
    todo.id
  end
  
  def list_contexts(username, token)
    check_token_against_user_word(username, token)
    
    @user.contexts
  end
  
  def list_projects(username, token)
    check_token_against_user_word(username, token)
    
    @user.projects
  end
  
  private

    # Check whether the token in the URL matches the word in the User's table
    def check_token_against_user_word(username, token)
      @user = User.find_by_login( username )
      unless (token == @user.word)
        raise(InvalidToken, "Sorry, you don't have permission to perform this action.")
      end
    end
    
    def check_context_belongs_to_user(context_id)
      unless @user.contexts.exists? context_id
        raise(CannotAccessContext, "Cannot access a context that does not belong to this user.")
      end
    end
    
    def create_todo(description, context_id, project_id = nil)
      item = @user.todos.build
      item.description = description
      item.context_id = context_id
      item.project_id = project_id unless project_id.nil?
      item.save
      raise item.errors.full_messages.to_s if item.new_record?
      item
    end
    
    def split_by_char(separator,string)
      parts = string.split(separator)
      return safe_strip(parts[0]), safe_strip(parts[1])
    end
    
    def safe_strip(s)
      s.strip! unless s.nil?
      s
    end
end

class InvalidToken < RuntimeError; end
class CannotAccessContext < RuntimeError; end
