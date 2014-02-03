module RecurringTodos

  class AbstractRecurringTodosBuilder 

    def initialize(user, attributes)
      @user = user
      @attributes = attributes
      @filterred_attributes = filter_attributes(@attributes)
      @saved = false
    end

    def filter_generic_attributes(attributes)
      {
        recurring_period: attributes["recurring_period"],
        description:      attributes['description'], 
        notes:            attributes['notes'],
        tag_list:         tag_list_or_empty_string(attributes),
        start_from:       attributes['start_from'],
        end_date:         attributes['end_date'],
        ends_on:          attributes['ends_on'],
        show_always:      attributes['show_always'],
        target:           attributes['target'],
        project:          attributes[:project],
        context:          attributes[:context],
        target:           attributes['recurring_target'],
        show_from_delta:  attributes['recurring_show_days_before'],
        show_always:      attributes['recurring_show_always']
      }
    end

    # build does not add tags. For tags, the recurring todos needs to be saved
    def build
      @recurring_todo = @pattern.build_recurring_todo

      @recurring_todo.context = @filterred_attributes[:context]
      @recurring_todo.project = @filterred_attributes[:project]
    end

    def update(recurring_todo)
      @recurring_todo = @pattern.update_recurring_todo(recurring_todo)
      @recurring_todo.context = @filterred_attributes[:context]
      @recurring_todo.project = @filterred_attributes[:project]
      
      @saved = @recurring_todo.save
      @recurring_todo.tag_with(@filterred_attributes[:tag_list]) if @saved && @filterred_attributes[:tag_list].present?
      return @saved
    end

    def save
      build
      @saved = @recurring_todo.save
      @recurring_todo.tag_with(@filterred_attributes[:tag_list]) if @saved && @filterred_attributes[:tag_list].present?
      return @saved
    end

    def saved_recurring_todo
      if !@saved
        raise Exception.new, @recurring_todo.valid? ? "Recurring todo was not saved yet" : "Recurring todos was not saved because of validation errors"
      end

      @recurring_todo
    end

    def attributes
      @pattern.attributes
    end

    def attributes_to_filter
      raise Exception.new, "attributes_to_filter should be overridden"
    end

    def filter_attributes(attributes)
      @filterred_attributes = filter_generic_attributes(attributes)
      attributes_to_filter.each{|key| @filterred_attributes[key] = attributes[key] if attributes.key?(key)}
      @filterred_attributes
    end

    private

    def tag_list_or_empty_string(attributes)
      # avoid nil
      attributes['tag_list'].blank? ? "" : attributes['tag_list'].strip
    end

  end

end 