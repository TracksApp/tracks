class MobileController < ApplicationController
  
  model :user
  model :project
  model :context
  model :todo
  
  layout 'mobile'
  
  prepend_before_filter :login_required
  
  # Plain list of all next actions, paginated 6 per page
  # Sorted by due date, then creation date
  #
  def list
    self.init
    @page_title = @desc = "All actions"
    @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
            :conditions => ['user_id = ? and state = ?', @user.id, "active"],
            :per_page => 6 )
    @count = @all_todos.reject { |x| !x.active? || x.context.hide? }.size
  end

  def detail
    self.init
    @item = check_user_return_item
    @place = @item.context.id
  end
  
  def update_action
    if params[:id]
      @item = check_user_return_item 
    else
      if params[:item][:"show_from(1i)"] == ""
        @item = Todo.create(params[:item]) if params[:item]
      else
        @item = Todo.create(params[:item]) if params[:item]
        @item.defer!
      end
    end
    
    @item.user_id = @user.id
    
    if @item.save
      redirect_to :action => 'list'
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
    self.init
  end
  
  def filter
    self.init
    @type = params[:type]
    case params[:type]
      when 'context'
        @context = Context.find( params[:context][:id] )
        @page_title = @desc = "#{@context.name}"
        @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and state = ? and context_id = ?', @user.id, "active", @context.id], :per_page => 6 )
        @count = @all_todos.reject { |x| x.completed? || x.context_id != @context.id }.size
      when 'project'
        @project = Project.find( params[:project][:id] )
        @page_title = @desc = "#{@project.name}"
        @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and state = ? and project_id = ?', @user.id, "active", @project.id], :per_page => 6 )
        @count = @all_todos.reject { |x| x.completed? || x.project_id != @project.id }.size
    end
  end
  
  protected

  def check_user_return_item
    item = Todo.find( params['id'] )
    if @user == item.user
      return item
    else
      flash[:warning] = "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
      render_text ""
    end
  end

  def init
    @contexts = @user.contexts.find(:all, :order => 'position ASC')
    @projects = @user.projects.find_in_state(:all, :active, :order => 'position ASC')
    @all_todos = @user.todos.find(:all, :conditions => ['state = ? or state =?', "active", "completed"])
  end
  
end
