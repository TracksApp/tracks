class UserController < ApplicationController
  scaffold :user
  
  def index
    render_text "This will be our jumping-off point for managing user functions!"
  end
  
  def admin
    render_text "You'll only be allowed to go here if you're an administrator."
  end
end