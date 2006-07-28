class DeferredController < ApplicationController

  model :user
  model :project
  model :context

  helper :todo

  prepend_before_filter :login_required
  layout "standard"

  
  def index
    init_projects_and_contexts
    init_not_done_counts
    @page_title = "TRACKS::Tickler"
    @tickles = @user.todos.find(:all, :conditions => ['type = ?', "Deferred"], :order => "show_from ASC")
    @count = @tickles.size
  end
  
  def create
    @item = Deferred.create(params["todo"])
    @item.user_id = @user.id

    if @item.due?
      @item.due = Date.strptime(params["todo"]["due"], @user.preferences["date_format"])
    else
      @item.due = ""
    end

    @saved = @item.save

     if @saved
       @up_count = @user.todos.count(['type = ?', "Deferred"])
     end

     respond_to do |wants|
       wants.html { redirect_to :action => "index" }
       wants.js
       wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end
  
  def edit
    init_projects_and_contexts
    @item = check_user_return_item
    render :layout => false
  end
  
  def update
    @item = check_user_return_item
    @original_item_context_id = @item.context_id
    @item.attributes = params["item"]

    if @item.due?
      @item.due = Date.strptime(params["item"]["due"], @user.preferences["date_format"])
    else
      @item.due = ""
    end

    @saved = @item.save
  end
  
  def destroy
    @item = check_user_return_item
    context_id = @item.context_id
    @saved = @item.destroy
    
    respond_to do |wants|
      wants.html do
        flash["notice"] = 'Successfully deleted next action' if @saved
        redirect_to :action => "index"
      end
      wants.js do
        @down_count = @user.todos.count(['type = ?', "Deferred"]) if @saved
        render
      end
      wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
    end
    
    rescue
      respond_to do |wants|
        wants.html do
          flash["warning"] = 'An error occurred on the server.'
          redirect_to :action => "index"
        end
        wants.js  { render :action => 'error' }
        wants.xml { render :text => "500 Server Error: There was an error deleting the action.", :status => 500 }
      end
  end
  
  # Check for any due tickler items, change them to type Immediate.
  # Called by periodically_call_remote
  def check_tickler
    now = Date.today()
    @due_tickles = @user.todos.find(:all, :conditions => ['type = ? AND (show_from < ? OR show_from = ?)', "Deferred", now, now ], :order => "show_from ASC")
    # Change the due tickles to type "Immediate"
    @due_tickles.each do |t|
      t[:type] = "Immediate"
      t.show_from = nil
      t.save_with_validation(false)
    end
  end
  
  protected
  
  def init_projects_and_contexts
    @projects = @user.projects
    @contexts = @user.contexts
  end
  
  private
  
  def check_user_return_item
    item = Todo.find( params['id'] )
    if @user == item.user
      return item
    else
      flash["warning"] = "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
      render_text ""
    end
  end
    
end