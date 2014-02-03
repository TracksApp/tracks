module RecurringTodos

  class AbstractRepeatPattern

    def initialize(user, attributes)
      @user = user
      @attributes = attributes
      @filterred_attributes = nil
    end

    def build_recurring_todo
      @recurring_todo = @user.recurring_todos.build(mapped_attributes)
    end

    def update_recurring_todo(recurring_todo)
      recurring_todo.assign_attributes(mapped_attributes)
      recurring_todo
    end

    def mapped_attributes
      # should be overwritten to map attributes to activerecord model
      @attributes
    end

    def attributes
      mapped_attributes
    end
    
    def map(mapping, key, source_key)
      mapping[key] = mapping[source_key]
      mapping.except(source_key)
    end

    def get_selector(key)
      raise Exception.new, "recurrence selector pattern (#{key}) not given" unless @attributes.key?(key)
      raise Exception.new, "unknown recurrence selector pattern: '#{@attributes[key]}'" unless valid_selector?(@attributes[key])

      selector = @attributes[key]
      @attributes = @attributes.except(key)
      return selector
    end

    def valid_selector?(selector)
      raise Exception.new, "valid_selector? should be overridden in subclass of AbstractRepeatPattern"
    end

  end
  
end