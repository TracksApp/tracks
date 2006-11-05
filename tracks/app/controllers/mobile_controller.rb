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
            :conditions => ['user_id = ? and type = ? and done = ?', @user.id, "Immediate", false],
            :per_page => 6 )
    @count = @all_todos.reject { |x| x.done? || x.context.hide? }.size
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
        @item = Immediate.create(params[:item]) if params[:item]
      else
        @item = Deferred.create(params[:item]) if params[:item]
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
          :conditions => ['user_id = ? and type = ? and done = ? and context_id = ?', @user.id, "Immediate", false, @context.id], :per_page => 6 )
        @count = @all_todos.reject { |x| x.done? || x.context_id != @context.id }.size
      when 'project'
        @project = Project.find( params[:project][:id] )
        @page_title = @desc = "#{@project.name}"
        @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and type = ? and done = ? and project_id = ?', @user.id, "Immediate", false, @project.id], :per_page => 6 )
        @count = @all_todos.reject { |x| x.done? || x.project_id != @project.id }.size
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
    @contexts = Context.find :all, :order => 'position ASC', 
                             :conditions => ['user_id = ?', @user.id]
    @projects = Project.find :all, :order => 'position ASC', 
                             :conditions => ['user_id = ? and state = ?', @user.id, "active"]
    @all_todos = Todo.find(:all, :conditions => ['user_id = ? and type = ?', @user.id, "Immediate"])
  end
  
end
