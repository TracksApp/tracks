module RecurringTodos

  class MonthlyRepeatPattern < AbstractRepeatPattern

    def initialize(user, attributes)
      super user, attributes
      @selector = get_selector('monthly_selector')
    end

    def mapped_attributes
      mapping = @attributes

      mapping = map(mapping, :every_other1, 'monthly_every_x_day')
      mapping = map(mapping, :every_other3, 'monthly_every_xth_day')
      mapping = map(mapping, :every_count,  'monthly_day_of_week')

      mapping[:every_other2] = mapping[get_every_other2]
      mapping = mapping.except('monthly_every_x_month').except('monthly_every_x_month2')

      mapping[:recurrence_selector] = get_recurrence_selector

      mapping
    end

    def every_x_day?
      @recurring_todo.recurrence_selector == 0
    end

    def every_xth_day?
      @recurring_todo.recurrence_selector == 1
    end

    private

    def get_recurrence_selector
      @selector=='monthly_every_x_day' ? 0 : 1
    end  

    def get_every_other2
      get_recurrence_selector == 0 ? 'monthly_every_x_month' : 'monthly_every_x_month2'
    end

    def valid_selector?(selector)
      %w{monthly_every_x_day monthly_every_xth_day}.include?(selector)
    end

  end
  
end