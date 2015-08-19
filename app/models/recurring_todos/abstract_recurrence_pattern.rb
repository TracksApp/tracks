module RecurringTodos

  class AbstractRecurrencePattern

    attr_accessor :attributes

    def initialize(user)
      @user = user
    end

    def start_from
      get :start_from
    end

    def end_date
      get :end_date
    end

    def ends_on
      get :ends_on
    end

    def target
      get :target
    end

    def show_always?
      get :show_always
    end

    def show_from_delta
      get :show_from_delta
    end

    def number_of_occurrences
      get :number_of_occurrences
    end

    def recurring_target_as_text
      target == 'due_date' ? I18n.t("todos.recurrence.pattern.due") : I18n.t("todos.recurrence.pattern.show")
    end

    def recurrence_pattern
      raise "Should not call AbstractRecurrencePattern.recurrence_pattern directly. Overwrite in subclass"
    end

    def xth(x)
      xth_day = [
        I18n.t('todos.recurrence.pattern.first'),I18n.t('todos.recurrence.pattern.second'),I18n.t('todos.recurrence.pattern.third'),
        I18n.t('todos.recurrence.pattern.fourth'),I18n.t('todos.recurrence.pattern.last')]
      x.nil? ? '??' : xth_day[x-1]
    end

    def day_of_week_as_text(day)
      day.nil? ? '??' : I18n.t('todos.recurrence.pattern.day_names')[day]
    end

    def month_of_year_as_text(month)
      month.nil? ? '??' : I18n.t('todos.recurrence.pattern.month_names')[month]
    end

    def build_recurring_todo(attribute_handler)
      @recurring_todo = @user.recurring_todos.build(attribute_handler.safe_attributes)
    end

    def update_recurring_todo(recurring_todo, attribute_handler)
      recurring_todo.assign_attributes(attribute_handler.safe_attributes)
      recurring_todo
    end

    def build_from_recurring_todo(recurring_todo)
      @recurring_todo = recurring_todo
      @attributes = Tracks::AttributeHandler.new(@user, recurring_todo.attributes)
    end

    def valid?
      @recurring_todo.valid?
    end

    def validate_not_blank(object, msg)
      errors[:base] << msg if object.blank?
    end

    def validate_not_nil(object, msg)
      errors[:base] << msg if object.nil?
    end

    def validate
      starts_and_ends_on_validations
      set_recurrence_on_validations
    end

    def starts_and_ends_on_validations
      validate_not_blank(start_from, "The start date needs to be filled in")
      case ends_on
      when 'ends_on_number_of_times'
        validate_not_blank(number_of_occurrences, "The number of recurrences needs to be filled in for 'Ends on'")
      when "ends_on_end_date"
        validate_not_blank(end_date, "The end date needs to be filled in for 'Ends on'")
      else
        errors[:base] << "The end of the recurrence is not selected" unless ends_on == "no_end_date"
      end
    end

    def set_recurrence_on_validations
      # show always or x days before due date. x not null
      case target
      when 'show_from_date'
        # no validations
      when 'due_date'
        validate_not_nil(show_always?, "Please select when to show the action")
        validate_not_blank(show_from_delta, "Please fill in the number of days to show the todo before the due date") unless show_always?
      else
        errors[:base] << "Unexpected value of recurrence target selector '#{target}'"
      end
    end

    def errors
      @recurring_todo.errors
    end

    def get(attribute)
      @attributes[attribute]
    end

    # gets the next due date. returns nil if recurrence_target is not 'due_date'
    def get_due_date(previous)
      case target
      when 'due_date'
        get_next_date(previous)
      when 'show_from_date'
        nil
      end
    end

    def get_show_from_date(previous)
      case target
      when 'due_date'
        # so set show from date relative to due date unless show_always is true or show_from_delta is nil
        return nil unless put_in_tickler?
        get_due_date(previous) - show_from_delta.days
      when 'show_from_date'
        # Leave due date empty
        get_next_date(previous)
      end
    end

    # checks if the next todos should be put in the tickler for recurrence_target == 'due_date'
    def put_in_tickler?
      !( show_always? || show_from_delta.nil?)
    end

    def get_next_date(previous)
      raise "Should not call AbstractRecurrencePattern.get_next_date directly. Override in subclass"
    end

    def continues_recurring?(previous)
      return @recurring_todo.occurrences_count < @recurring_todo.number_of_occurrences unless @recurring_todo.number_of_occurrences.nil?
      return true if self.end_date.nil? || self.ends_on == 'no_end_date'

      case self.target
      when 'due_date'
        get_due_date(previous) <= self.end_date
      when 'show_from_date'
        get_show_from_date(previous) <= self.end_date
      end
    end

    private

    # Determine start date to calculate next date for recurring todo which
    # takes start_from and previous into account.
    # offset needs to be 1.day for daily patterns or the start will be the
    # same day as the previous
    def determine_start(previous, offset=0.day)
      start = self.start_from || NullTime.new
      if previous
        # check if the start_from date is later than previous. If so, use
        # start_from as start to search for next date
        start > previous ? start : previous + offset
      else
        # skip to present
        now = Time.zone.now
        start > now ? start : now
      end
    end

    # Example: get 3rd (x) wednesday  (weekday) of december (month) 2014 (year)
    # 5th means last, so it will return the 4th if there is no 5th
    def get_xth_day_of_month(x, weekday, month, year)
      raise "Weekday should be between 0 and 6 with 0=sunday. You supplied #{weekday}" unless (0..6).cover?(weekday)
      raise "x should be 1-4 for first-fourth or 5 for last. You supplied #{x}" unless (0..5).cover?(x)

      if x == 5
        return find_last_day_x_of_month(weekday, month, year)
      else
        return find_xth_day_of_month(x, weekday, month, year)
      end
    end

    def find_last_day_x_of_month(weekday, month, year)
      last_day = Time.zone.local(year, month, Time.days_in_month(month))
      while last_day.wday != weekday
        last_day -= 1.day
      end
      last_day
    end

    def find_xth_day_of_month(x, weekday, month, year)
      start = Time.zone.local(year,month,1)
      n = x
      while n > 0
        while start.wday() != weekday
          start += 1.day
        end
        n -= 1
        start += 1.day unless n==0
      end
      start
    end
  end
end
