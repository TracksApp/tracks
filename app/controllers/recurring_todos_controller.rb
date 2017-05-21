class RecurringTodosController < ApplicationController

  helper :todos, :recurring_todos

  append_before_action :init, :only => [:index, :new, :edit, :create]
  append_before_action :get_recurring_todo_from_param, :only => [:destroy, :toggle_check, :toggle_star, :edit, :update]

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
    @source_view = params['_source_view'] || 'recurring_todo'
    @page_title = t('todos.completed_recurring_actions_title')

    items_per_page = 20
    page = params[:page] || 1
    @completed_recurring_todos = current_user.recurring_todos.completed.paginate :page => page, :per_page => items_per_page
    @total = @count = current_user.recurring_todos.completed.count

    @range_low = (page.to_i-1) * items_per_page + 1
    @range_high = @range_low + @completed_recurring_todos.size - 1

    @range_low = 0 if @total == 0
    @range_high = @total if @range_high > @total
  end

  def edit
    @form_helper = RecurringTodos::FormHelper.new(@recurring_todo)

    respond_to do |format|
      format.js
    end
  end

  def update
    updater = RecurringTodos::RecurringTodosBuilder.new(current_user, update_recurring_todo_params)
    @saved = updater.update(@recurring_todo)

    @recurring_todo.reload

    respond_to do |format|
      format.js
    end
  end

  def create
    builder = RecurringTodos::RecurringTodosBuilder.new(current_user, all_recurring_todo_params)
    @saved = builder.save

    if @saved
      @recurring_todo = builder.saved_recurring_todo
      todo_saved = TodoFromRecurringTodo.new(current_user, @recurring_todo).create.nil? == false

      @status_message =
        t('todos.recurring_action_saved') + " / " +
        t("todos.new_related_todo_#{todo_saved ? "" : "not_"}created_short")

      @down_count = current_user.recurring_todos.active.count
      @new_recurring_todo = RecurringTodo.new
    else
      @recurring_todo = builder.recurring_todo
      @status_message = t('todos.error_saving_recurring')
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @number_of_todos = @recurring_todo.todos.count

    # remove all references to this recurring todo
    @recurring_todo.clear_todos_association

    # delete the recurring todo
    @saved = @recurring_todo.destroy

    # count remaining recurring todos
    @active_remaining = current_user.recurring_todos.active.count
    @completed_remaining = current_user.recurring_todos.completed.count

    respond_to do |format|

      format.html do
        if @saved
          notify :notice, t('todos.recurring_deleted_success')
        else
          notify :error,  t('todos.error_deleting_recurring', :description => @recurring_todo.description)
        end
        redirect_to :action => 'index'
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

  private

  def recurring_todo_params
    params.require(:recurring_todo).permit(
      # model attributes
      :context_id, :project_id, :description, :notes, :state, :start_from,
      :ends_on, :end_date, :number_of_occurrences, :occurrences_count, :target,
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
      # derived attributes
      :weekly_return_monday, :weekly_return_tuesday, :weekly_return_wednesday,
      :weekly_return_thursday, :weekly_return_friday, :weekly_return_saturday, :weekly_return_sunday
      )
  end

  def all_recurring_todo_params
    # move context_name, project_name and tag_list into :recurring_todo hash for easier processing
    {
      context_name: :context_name,
      project_name: :project_name,
      tag_list:     :tag_list
    }.each do |target,source|
      move_into_recurring_todo_param(params, target, source)
    end
    recurring_todo_params
  end

  def update_recurring_todo_params
    # we needed to rename the recurring_period selector in the edit form because
    # the form for a new recurring todo and the edit form are on the same page.
    # Same goes for start_from and end_date
    params['recurring_todo']['recurring_period'] = params['recurring_edit_todo']['recurring_period']

    {
      context_name: :context_name,
      project_name: :project_name,
      tag_list:     :edit_recurring_todo_tag_list,
      end_date:     :recurring_todo_edit_end_date,
      start_from:   :recurring_todo_edit_start_from
    }.each do |target,source|
      move_into_recurring_todo_param(params, target, source)
    end

    # make sure that we set weekly_return_xxx to empty (space) when they are
    # not checked (and thus not present in params["recurring_todo"])
    %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
      params["recurring_todo"]["weekly_return_#{day}"]=' ' if params["recurring_todo"]["weekly_return_#{day}"].nil?
    end

    recurring_todo_params
  end

  def move_into_recurring_todo_param(params, target, source)
    params[:recurring_todo][target] = params[source] unless params[source].blank?
  end

  def init
    @days_of_week   = (0..6).map{|i| [t('date.day_names')[i], i] }
    @months_of_year = (1..12).map{|i| [t('date.month_names')[i], i] }
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
