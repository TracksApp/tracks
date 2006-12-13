class MobileController < ApplicationController

  layout 'mobile'
  
  before_filter :init, :except => :update
  
  # Plain list of all next actions, paginated 6 per page
  # Sorted by due date, then creation date
  #
  def index
    @page_title = @desc = "All actions"
    @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
            :conditions => ['user_id = ? and state = ?', @user.id, "active"],
            :per_page => 6 )
    @count = @all_todos.reject { |x| !x.active? || x.context.hide? }.size
  end

  def detail
    @item = check_user_return_item
    @place = @item.context.id
  end
  
  def update
    if params[:id]
      @item = check_user_return_item
      @item.update_attributes params[:item]
      if params[:item][:state] == "1"
        @item.state = "completed"
      else
        @item.state = "active"
      end
    else
      params[:item][:user_id] = @user.id
      @item = Todo.new(params[:item]) if params[:item]
    end
        
    if @item.save
      redirect_to :action => 'index'
    else
      self.init
      if params[:id]
        render :partial => 'mobile_edit'
      else
        render :action => 'show_add_form'
      end
    end
  end

  def show_add_form
    # Just render the view
  end
  
  def filter
    @type = params[:type]
    case params[:type]
      when 'context'
        @context = Context.find( params[:context][:id] )
        @page_title = @desc = "#{@context.name}"
        @todos = Todo.find( :all, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and state = ? and context_id = ?', @user.id, "active", @context.id] )
        @count = @all_todos.reject { |x| x.completed? || x.context_id != @context.id }.size
      when 'project'
        @project = Project.find( params[:project][:id] )
        @page_title = @desc = "#{@project.name}"
        @todos = Todo.find( :all, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and state = ? and project_id = ?', @user.id, "active", @project.id] )
        @count = @all_todos.reject { |x| x.completed? || x.project_id != @project.id }.size
    end
  end
  
  protected

  def check_user_return_item
    item = Todo.find( params['id'] )
    if @user == item.user
      return item
    else
      notify :warning, "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
      render_text ""
    end
  end

  def init
    @contexts = @user.contexts.find(:all, :order => 'position ASC')
    @projects = @user.projects.find_in_state(:all, :active, :order => 'position ASC')
    @all_todos = @user.todos.find(:all, :conditions => ['state = ? or state = ?', "active", "completed"])
  end
  
end
