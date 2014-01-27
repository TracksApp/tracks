class RecurringTodosController < ApplicationController

  helper :todos, :recurring_todos

  append_before_filter :init, :only => [:index, :new, :edit, :create]
  append_before_filter :get_recurring_todo_from_param, :only => [:destroy, :toggle_check, :toggle_star, :edit, :update]

  def index
    @page_title = t('todos.recurring_actions_title')
    @source_view = params['_source_view'] || 'recurring_todo'
    find_and_inactivate
    @recurring_todos = current_user.recurring_todos.active.includes(:tags, :taggings)
    @completed_recurring_todos = current_user.recurring_todos.completed.limit(10).includes(:tags, :taggings)

    @no_recurring_todos = @recurring_todos.count == 0
    @no_completed_recurring_todos = @completed_recurring_todos.count == 0
    @count = @recurring_todos.count

    @new_recurring_todo = RecurringTodo.new
  end

  def new
  end

  def show
  end

  def done
    @page_title = t('todos.completed_recurring_actions_title')
    @source_view = params['_source_view'] || 'recurring_todo'
    items_per_page = 20
    page = params[:page] || 1
    @completed_recurring_todos = current_user.recurring_todos.completed.paginate :page => params[:page], :per_page => items_per_page
    @total = @count = current_user.recurring_todos.completed.count
    @range_low = (page.to_i-1) * items_per_page + 1
    @range_high = @range_low + @completed_recurring_todos.size - 1
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    # TODO: write tests for updating
    @recurring_todo.tag_with(params[:edit_recurring_todo_tag_list]) if params[:edit_recurring_todo_tag_list]
    @original_item_context_id = @recurring_todo.context_id
    @original_item_project_id = @recurring_todo.project_id

    # we needed to rename the recurring_period selector in the edit form because
    # the form for a new recurring todo and the edit form are on the same page.
    # Same goes for start_from and end_date
    params['recurring_todo']['recurring_period']=params['recurring_edit_todo']['recurring_period']
    params['recurring_todo']['end_date']=parse_date_per_user_prefs(params['recurring_todo_edit_end_date'])
    params['recurring_todo']['start_from']=parse_date_per_user_prefs(params['recurring_todo_edit_start_from'])

    # update project
    if params['recurring_todo']['project_id'].blank? && !params['project_name'].nil?
      if params['project_name'] == 'None'
        project = Project.null_object
      else
        project = current_user.projects.where(:name => params['project_name'].strip)
        unless project
          project = current_user.projects.build
          project.name = params['project_name'].strip
          project.save
          @new_project_created = true
        end
      end
      params["recurring_todo"]["project_id"] = project.id
    end

    # update context
    if params['recurring_todo']['context_id'].blank? && params['context_name'].present?
      context = current_user.contexts.where(:name => params['context_name'].strip).first
      unless context
        context = current_user.contexts.build
        context.name = params['context_name'].strip
        context.save
        @new_context_created = true
      end
      params["recurring_todo"]["context_id"] = context.id
    end

    # make sure that we set weekly_return_xxx to empty (space) when they are
    # not checked (and thus not present in params["recurring_todo"])
    %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
      params["recurring_todo"]["weekly_return_"+day]=' ' if params["recurring_todo"]["weekly_return_"+day].nil?
    end

    selector_attributes = {
        'recurring_period' => recurring_todo_params['recurring_period'],
        'daily_selector' => recurring_todo_params['daily_selector'],
        'monthly_selector' => recurring_todo_params['monthly_selector'],
        'yearly_selector' => recurring_todo_params['yearly_selector']
      }

    @recurring_todo.assign_attributes(:recurring_period => recurring_todo_params[:recurring_period])
    @recurring_todo.assign_attributes(selector_attributes)
    @saved = @recurring_todo.update_attributes recurring_todo_params

    respond_to do |format|
      format.js
    end
  end

  def create
    builder = RecurringTodos::RecurringTodosBuilder.new(current_user, all_recurring_todo_params)
    @saved = builder.save
    @recurring_todo = builder.saved_recurring_todo

    if @saved
      @status_message = t('todos.recurring_action_saved')
      @todo_saved = TodoFromRecurringTodo.new(current_user, @recurring_todo).create.nil? == false
      if @todo_saved
        @status_message += " / " + t('todos.new_related_todo_created_short')
      else
        @status_message += " / " + t('todos.new_related_todo_not_created_short')
      end
      @down_count = current_user.recurring_todos.active.count
      @new_recurring_todo = RecurringTodo.new
    else
      @status_message = t('todos.error_saving_recurring')
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    # remove all references to this recurring todo
    @todos = @recurring_todo.todos
    @number_of_todos = @todos.size
    @todos.each do |t|
      t.recurring_todo_id = nil
      t.save
    end

    # delete the recurring todo
    @saved = @recurring_todo.destroy

    # count remaining recurring todos
    @active_remaining = current_user.recurring_todos.active.count
    @completed_remaining = current_user.recurring_todos.completed.count

    respond_to do |format|

      format.html do
        if @saved
          notify :notice, t('todos.recurring_deleted_success')
          redirect_to :action => 'index'
        else
          notify :error, t('todos.error_deleting_recurring', :description => @recurring_todo.description)
          redirect_to :action => 'index'
        end
      end

      format.js do
        render
      end
    end
  end

  def toggle_check
    @saved = @recurring_todo.toggle_completion!

    @down_count = current_user.recurring_todos.active.count
    @active_remaining = @down_count
    @completed_remaining = 0

    if @recurring_todo.active?
      @completed_remaining = current_user.recurring_todos.completed.count

      # from completed back to active -> check if there is an active todo
      @active_todos = @recurring_todo.todos.active.count
      # create todo if there is no active todo belonging to the activated
      # recurring_todo
      @new_recurring_todo = TodoFromRecurringTodo.new(current_user, @recurring_todo).create if @active_todos == 0
    end

    respond_to do |format|
      format.js
    end
  end

  def toggle_star
    @recurring_todo.toggle_star!
    @saved = @recurring_todo.save!
    respond_to do |format|
      format.js
    end
  end

  class RecurringTodoCreateParamsHelper

    def initialize(params, recurring_todo_params)
      @params = params['request'] || params
      @attributes = recurring_todo_params

      # make sure all selectors (recurring_period, recurrence_selector,
      # daily_selector, monthly_selector and yearly_selector) are first in hash
      # so that they are processed first by the model
      @selector_attributes = {
        'recurring_period' => @attributes['recurring_period'],
        'daily_selector' => @attributes['daily_selector'],
        'monthly_selector' => @attributes['monthly_selector'],
        'yearly_selector' => @attributes['yearly_selector']
      }
    end

    def attributes
      @attributes
    end

    def selector_attributes
      return @selector_attributes
    end

    def project_name
      @params['project_name'].strip unless @params['project_name'].nil?
    end

    def context_name
      @params['context_name'].strip unless @params['context_name'].nil?
    end

    def tag_list
      @params['tag_list']
    end

    def project_specified_by_name?
      return false if @attributes['project_id'].present?
      return false if project_name.blank?
      return false if project_name == 'None'
      true
    end

    def context_specified_by_name?
      return false if @attributes['context_id'].present?
      return false if context_name.blank?
      true
    end

  end

  private

  def recurring_todo_params
    params.require(:recurring_todo).permit(
      # model attributes
      :context_id, :project_id, :description, :notes, :state, :start_from, 
      :ends_on, :end_date, :number_of_occurences, :occurences_count, :target, 
      :show_from_delta, :recurring_period, :recurrence_selector, :every_other1, 
      :every_other2, :every_other3, :every_day, :only_work_days, :every_count, 
      :weekday, :show_always, :context_name, :project_name, :tag_list,
      # form attributes
      :recurring_period, :daily_selector, :monthly_selector, :yearly_selector, 
      :recurring_target, :daily_every_x_days, :monthly_day_of_week, 
      :monthly_every_x_day, :monthly_every_x_month2, :monthly_every_x_month, 
      :monthly_every_xth_day, :recurring_show_days_before, 
      :recurring_show_always, :weekly_every_x_week, :weekly_return_monday,
      :yearly_day_of_week, :yearly_every_x_day, :yearly_every_xth_day, 
      :yearly_month_of_year2, :yearly_month_of_year,
      # derived attribues
      :weekly_return_monday, :weekly_return_tuesday, :weekly_return_wednesday, 
      :weekly_return_thursday, :weekly_return_friday, :weekly_return_saturday, :weekly_return_sunday
      )
  end

  def all_recurring_todo_params    
    # move context_name, project_name and tag_list into :recurring_todo hash for easier processing
    params[:recurring_todo][:context_name] = params[:context_name] unless params[:context_name].blank?
    params[:recurring_todo][:project_name] = params[:project_name] unless params[:project_name].blank?
    params[:recurring_todo][:tag_list] =     params[:tag_list]     unless params[:tag_list].blank?
    recurring_todo_params
  end

  def init
    @days_of_week = []
    0.upto 6 do |i|
      @days_of_week << [t('date.day_names')[i], i]
    end

    @months_of_year = []
    1.upto 12 do |i|
      @months_of_year << [t('date.month_names')[i], i]
    end

    @xth_day = [[t('common.first'),1],[t('common.second'),2],[t('common.third'),3],[t('common.fourth'),4],[t('common.last'),5]]
    @projects = current_user.projects.includes(:default_context)
    @contexts = current_user.contexts
  end

  def get_recurring_todo_from_param
    @recurring_todo = current_user.recurring_todos.find(params[:id])
  end

  def find_and_inactivate
    # find active recurring todos without active todos and inactivate them

    current_user.recurring_todos.active.
      select("recurring_todos.id, recurring_todos.state").
      joins("LEFT JOIN todos fai_todos ON (recurring_todos.id = fai_todos.recurring_todo_id) AND (NOT fai_todos.state='completed')").
      where("fai_todos.id IS NULL").
      each { |rt| current_user.recurring_todos.find(rt.id).toggle_completion! }
  end

end
