module RecurringTodos

  class WeeklyRepeatPattern < AbstractRepeatPattern

    def initialize(user)
      super user
    end

    def every_x_week
      get :every_other1
    end

    { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 0 }.each do |day, number|
      define_method("on_#{day}") do
        on_xday number
      end
    end

    def on_xday(n)
      get(:every_day) && get(:every_day)[n, 1] != ' '
    end

    def validate
      super
      errors[:base] << "Every other nth week may not be empty for weekly recurrence setting" if every_x_week.blank?
      something_set = %w{sunday monday tuesday wednesday thursday friday saturday}.inject(false) { |set, day| set || self.send("on_#{day}") }
      errors[:base] << "You must specify at least one day on which the todo recurs" unless something_set
    end

  end
  
end