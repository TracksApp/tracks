class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_api TodoApi
  web_service_scaffold :invoke
  
  def new_todo(username, token, context_id, description)
    check_token_against_user_word(username, token)
    check_context_belongs_to_user(context_id)

    item = @user.todos.build
    item.description = description
    item.context_id = context_id
    item.save
    raise item.errors.full_messages.to_s if item.new_record?
    item.id
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
      unless ( token == @user.word)
        raise (InvalidToken, "Sorry, you don't have permission to perform this action.")
      end
    end
    
    def check_context_belongs_to_user(context_id)
      unless @user.contexts.exists? context_id
        raise (CannotAccessContext, "Cannot access a context that does not belong to this user.")
      end
    end
  
end

class InvalidToken < RuntimeError; end
class CannotAccessContext < RuntimeError; end
