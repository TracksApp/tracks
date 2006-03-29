class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_api TodoApi
  web_service_scaffold :invoke
  
  def new_todo(username, token, context_id, description)
    if !check_token_against_user_word(username, token)
      raise "invalid token"
    end

    item = @user.todos.build
    item.description = description
    item.context_id = context_id
    item.save
    raise item.errors.full_messages.to_s if item.new_record?
    item.id
  end
  
  protected

    # Check whether the token in the URL matches the word in the User's table
    def check_token_against_user_word(username, token)
      @user = User.find_by_login( username )
      unless ( token == @user.word)
        render :text => "Sorry, you don't have permission to perform this action."
        return false
      end
      true
    end
  
end
