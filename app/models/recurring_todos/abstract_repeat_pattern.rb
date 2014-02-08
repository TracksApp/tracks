module RecurringTodos

  class AbstractRepeatPattern

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

    def show_always
      get :show_always
    end

    def show_from_delta
      get :show_from_delta
    end

    def build_recurring_todo(attributes)
      @recurring_todo = @user.recurring_todos.build(attributes)
    end

    def update_recurring_todo(recurring_todo, attributes)
      recurring_todo.assign_attributes(attributes)
      recurring_todo
    end

    def build_from_recurring_todo(recurring_todo)
      @recurring_todo = recurring_todo
      @attributes = recurring_todo.attributes
    end

    def validate
      starts_and_ends_on_validations
      set_recurrence_on_validations
    end

    def starts_and_ends_on_validations
      errors[:base] << "The start date needs to be filled in" if start_from.blank?
      case ends_on
      when 'ends_on_number_of_times'
        errors[:base] << "The number of recurrences needs to be filled in for 'Ends on'" if number_of_occurences.blank?
      when "ends_on_end_date"
        errors[:base] << "The end date needs to be filled in for 'Ends on'" if end_date.blank?
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
        errors[:base] << "Please select when to show the action" if show_always.nil?
        unless show_always
          errors[:base] << "Please fill in the number of days to show the todo before the due date" if show_from_delta.blank?
        end
      else
        raise Exception.new, "unexpected value of recurrence target selector '#{target}'"
      end
    end

    def errors
      @recurring_todo.errors
    end

    def get attribute
      # handle attribute as symbol and as string
      @attributes[attribute] || @attributes[attribute.to_s]
    end

  end
  
end