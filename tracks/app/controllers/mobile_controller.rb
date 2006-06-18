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
      @item = @user.todos.build           
    end
    
    @item.attributes = params[:item]
    
    if @item.save
      redirect_to :action => 'list'
    else
      flash["warning"] = "Action could not be saved"
      redirect_to :action => 'list'
    end
  end

  def show_add_form
    self.init
  end
  
  def filter
    self.init
    case params[:type]
      when 'context'
        @context = Context.find( params[:context][:id] )
        @page_title = @desc = "#{@context.name}"
        @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and type = ? and done = ? and context_id = ?', @user.id, "Immediate", false, @context.id], :per_page => 6 )
      when 'project'
        @project = Project.find( params[:project][:id] )
        @page_title = @desc = "#{@project.name}"
        @todos_pages, @todos = paginate( :todos, :order =>  'due IS NULL, due ASC, created_at ASC',
          :conditions => ['user_id = ? and type = ? and done = ? and project_id = ?', @user.id, "Immediate", false, @project.id], :per_page => 6 )
    end
  end
  
  protected

  def check_user_return_item
    item = Todo.find( params['id'] )
    if @user == item.user
      return item
    else
      flash["warning"] = "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
      render_text ""
    end
  end

  def init
    @contexts = Context.find :all, :order => 'position ASC', 
                             :conditions => ['user_id = ?', @user.id]
    @projects = Project.find :all, :order => 'position ASC', 
                             :conditions => ['user_id = ? and done = ?', @user.id, false]
  end
  
end
