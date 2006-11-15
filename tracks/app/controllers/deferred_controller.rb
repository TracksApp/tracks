class DeferredController < ApplicationController

  model :user
  model :project
  model :context

  helper :todo

  prepend_before_filter :login_required
  layout "standard"

  
  def index
    @source_view = 'deferred'
    init_data_for_sidebar
    @page_title = "TRACKS::Tickler"
    @tickles = @user.todos.find_in_state(:all, :deferred, :order => "show_from ASC")
    @count = @tickles.size
  end
  
  def create
    @source_view = 'deferred'
    @item = Todo.new
    @item.defer!
    @item.attributes = params["todo"]
    if params["todo"]["show_from"] 
      @item.show_from = parse_date_per_user_prefs(params["todo"]["show_from"])
    end
    @item.user_id = @user.id

    if @item.due?
      @item.due = parse_date_per_user_prefs(params["todo"]["due"])
    else
      @item.due = ""
    end

    @saved = @item.save

     if @saved
       @up_count = @user.todos.count_in_state(:deferred)
     end

     respond_to do |wants|
       wants.html { redirect_to :action => "index" }
       wants.js
       wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end
  
  def edit
    @source_view = 'deferred'
    init_projects_and_contexts
    @item = check_user_return_item
    render :template => 'todo/edit.rjs'
  end
  
  def update
    @source_view = 'deferred'
    @item = check_user_return_item
    @original_item_context_id = @item.context_id
    @item.attributes = params["item"]

    if params["item"]["show_from"] 
      @item.show_from = parse_date_per_user_prefs(params["item"]["show_from"])
    end

    if @item.due?
      @item.due = parse_date_per_user_prefs(params["item"]["due"])
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
        flash[:notice] = 'Successfully deleted next action' if @saved
        redirect_to :action => "index"
      end
      wants.js do
        @down_count = @user.todos.count_in_state(:deferred) if @saved
        render
      end
      wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
    end
    
    rescue
      respond_to do |wants|
        wants.html do
          flash[:warning] = 'An error occurred on the server.'
          redirect_to :action => "index"
        end
        wants.js  { render :action => 'error' }
        wants.xml { render :text => "500 Server Error: There was an error deleting the action.", :status => 500 }
      end
  end
  
  # Check for any due tickler items, activate them
  # Called by periodically_call_remote
  def check_tickler
    now = Date.today()
    @due_tickles = @user.todos.find_in_state(:all, :deferred, :conditions => ['show_from < ? OR show_from = ?', now, now ], :order => "show_from ASC")
    # Change the due tickles to active
    @due_tickles.each do |t|
      t.activate!
      t.save
    end
    respond_to do |wants|
      wants.html { redirect_to :controller => 'todo', :action => 'index' }
      wants.js
    end
  end
    
  private
  
  def check_user_return_item
    item = Todo.find( params['id'] )
    if @user == item.user
      return item
    else
      flash[:warning] = "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
      render_text ""
    end
  end
    
end