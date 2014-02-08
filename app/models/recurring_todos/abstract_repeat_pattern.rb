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
        validate_not_blank(number_of_occurences, "The number of recurrences needs to be filled in for 'Ends on'")
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
        validate_not_nil(show_always, "Please select when to show the action")
        validate_not_blank(show_from_delta, "Please fill in the number of days to show the todo before the due date") unless show_always
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