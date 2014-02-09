require_relative '../../test_helper'

module RecurringTodos

  class RecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_create_builder_needs_selector
      assert_raise(Exception){ builder = RecurringTodosBuilder.new(@admin, {}) }
    end

    def test_create_builder_uses_selector
      builder = RecurringTodosBuilder.new(@admin, {'recurring_period' => "daily", 'daily_selector' => 'daily_every_work_day'}).builder
      assert builder.is_a?(DailyRecurringTodosBuilder)

      builder = RecurringTodosBuilder.new(@admin, {'recurring_period' => "weekly"}).builder
      assert builder.is_a?(WeeklyRecurringTodosBuilder)

      builder = RecurringTodosBuilder.new(@admin, {'recurring_period' => "monthly", 'monthly_selector' => 'monthly_every_x_day'}).builder
      assert builder.is_a?(MonthlyRecurringTodosBuilder)

      builder = RecurringTodosBuilder.new(@admin, {'recurring_period' => "yearly",  'yearly_selector' => 'yearly_every_x_day'}).builder
      assert builder.is_a?(YearlyRecurringTodosBuilder)
    end

    def test_dates_are_parsed
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily", 
        'daily_selector' => 'daily_every_work_day',
        'start_from' => "01/01/01",
        'end_date' => '05/05/05'
        })

      assert builder.attributes.get(:start_from).is_a?(ActiveSupport::TimeWithZone), "Dates should be parsed to ActiveSupport::TimeWithZone class"
      assert builder.attributes.get(:end_date).is_a?(ActiveSupport::TimeWithZone), "Dates should be parsed to ActiveSupport::TimeWithZone class"
    end

    def test_exisisting_project_is_used
      # test by project_name
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily",
        'project_name'     => @admin.projects.first.name, 
        'daily_selector'   => 'daily_every_work_day'})

      assert_equal @admin.projects.first, builder.project

      # test by project_id
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily", 
        'daily_selector'   => 'daily_every_work_day',
        'project_id'       => @admin.projects.first.id})

      assert_equal @admin.projects.first, builder.project
    end

    def test_not_exisisting_project_is_created
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily",
        'project_name'     => "my new project", 
        'daily_selector'   => 'daily_every_work_day', 
        'recurring_target' => 'due_date'})

      assert_equal "my new project", builder.project.name, "project should exist"
      assert !builder.project.persisted?, "new project should not be persisted before save"

      builder.save
      assert builder.project.persisted?, "new project should be persisted after save"
    end

    def test_exisisting_context_is_used
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily",
        'context_name'     => @admin.contexts.first.name,
        'daily_selector'   => 'daily_every_work_day'})

      assert_equal @admin.contexts.first, builder.context

      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily", 
        'daily_selector'   => 'daily_every_work_day',
        'context_id'       => @admin.contexts.first.id})

      assert_equal @admin.contexts.first, builder.context
    end

    def test_not_exisisting_context_is_created
      builder = RecurringTodosBuilder.new(@admin, {
        'recurring_period' => "daily",
        'context_name'     => "my new context",
        'daily_selector'   => 'daily_every_work_day', 
        'recurring_target' => 'due_date'})

      assert_equal "my new context", builder.context.name, "context should exist"
      assert !builder.context.persisted?, "new context should not be persisted before save"

      builder.save
      assert builder.context.persisted?, "new context should be persisted after save"
    end

    def test_project_is_optional
      attributes = {
        'recurring_period' => "daily",
        'description'      => "test",
        'context_name'     => "my new context",
        'daily_selector'   => 'daily_every_work_day', 
        'recurring_target' => 'show_from_date',
        'show_always'      => true,
        'start_from'       => '01/01/01',
        'ends_on'          => 'no_end_date'}

      builder = RecurringTodosBuilder.new(@admin, attributes)

      assert_nil builder.project, "project should not exist"
      builder.save
      assert_nil builder.saved_recurring_todo.project
    end

    def test_builder_can_update_description
      attributes = {
        'recurring_period' => "daily",
        'description'      => "test",
        'context_name'     => "my new context",
        'daily_selector'   => 'daily_every_work_day', 
        'recurring_target' => 'show_from_date',
        'show_always'      => true,
        'start_from'       => '01/01/01',
        'ends_on'          => 'no_end_date'}

      builder = RecurringTodosBuilder.new(@admin, attributes)
      builder.save
      rt = builder.saved_recurring_todo

      assert_equal "test", rt.description

      attributes['description'] = 'updated'

      updater = RecurringTodosBuilder.new(@admin, attributes)
      updater.update(rt)
      rt.reload

      assert_equal rt.id, builder.saved_recurring_todo.id
      assert_equal "updated", rt.description
    end

  end

end