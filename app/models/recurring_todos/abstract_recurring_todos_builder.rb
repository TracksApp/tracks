module RecurringTodos

  class AbstractRecurringTodosBuilder 

    attr_reader :mapped_attributes, :pattern

    def initialize(user, attributes, pattern_class)
      @user  = user
      @saved = false

      @attributes           = attributes
      @selector             = get_selector(selector_key)
      @filterred_attributes = filter_attributes(@attributes)
      @mapped_attributes    = map_attributes(@filterred_attributes)

      @pattern              = pattern_class.new(user)
      @pattern.attributes   = @mapped_attributes

    end

    # build does not add tags. For tags, the recurring todos needs to be saved
    def build
      @recurring_todo = @pattern.build_recurring_todo(@mapped_attributes)

    end

    def update(recurring_todo)
      @recurring_todo = @pattern.update_recurring_todo(recurring_todo, @mapped_attributes)
      @saved = @recurring_todo.save
      @recurring_todo.tag_with(@filterred_attributes.get(:tag_list)) if @saved && @filterred_attributes.get(:tag_list).present?
      @recurring_todo.reload
      
      return @saved
    end

    def save
      build
      @saved = @recurring_todo.save
      @recurring_todo.tag_with(@filterred_attributes.get(:tag_list)) if @saved && @filterred_attributes.get(:tag_list).present?
      return @saved
    end

    def save_collection(collection, collection_id)
      # save object (project or context) and add its id to @mapped_attributes and remove the object from the attributes
      object = @mapped_attributes.get(collection)
      object.save
      @mapped_attributes.set(collection_id, object.id)
      @mapped_attributes.except(collection)
    end

    def save_project
      save_collection(:project, :project_id)
    end

    def save_context
      save_collection(:context, :context_id)
    end

    def saved_recurring_todo      
      raise(Exception.new, @recurring_todo.valid? ? "Recurring todo was not saved yet" : "Recurring todos was not saved because of validation errors") unless @saved

      @recurring_todo
    end

    def attributes
      @pattern.attributes
    end

    def attributes_to_filter
      raise Exception.new, "attributes_to_filter should be overridden"
    end

    def filter_attributes(attributes)
      filterred_attributes = filter_generic_attributes(attributes)
      attributes_to_filter.each{|key| filterred_attributes.set(key, attributes.get(key)) if attributes.key?(key)}
      filterred_attributes
    end

    def filter_generic_attributes(attributes)
      return Tracks::AttributeHandler.new(@user, {
        recurring_period: attributes.get(:recurring_period),
        description:      attributes.get(:description), 
        notes:            attributes.get(:notes),
        tag_list:         tag_list_or_empty_string(attributes),
        start_from:       attributes.get(:start_from),
        end_date:         attributes.get(:end_date),
        ends_on:          attributes.get(:ends_on),
        show_always:      attributes.get(:show_always),
        target:           attributes.get(:target),
        project:          attributes.get(:project),
        context:          attributes.get(:context),
        project_id:       attributes.get(:project_id),
        context_id:       attributes.get(:context_id),
        target:           attributes.get(:recurring_target),
        show_from_delta:  attributes.get(:recurring_show_days_before),
        show_always:      attributes.get(:recurring_show_always)
      })
    end

    def map_attributes
      # should be overwritten by subclasses to map attributes to activerecord model attributes
      @filterred_attributes
    end

    # helper method to be used in mapped_attributes in subclasses
    def map(mapping, key, source_key)
      mapping.set(key, mapping.get(source_key))
      mapping.except(source_key)
    end

    # should return period specific selector like yearly_selector or daily_selector
    def selector_key
      raise Exception.new, "selector_key should be overridden in subclass of AbstractRecurringTodosBuilder"
    end      

    def get_selector(key)
      return nil if key.nil?

      raise Exception.new, "recurrence selector pattern (#{key}) not given" unless @attributes.selector_key_present?(key)
      selector = @attributes.get(key)

      raise Exception.new, "unknown recurrence selector pattern: '#{selector}'" unless valid_selector?(selector)

      @attributes = @attributes.except(key)
      return selector
    end

    def valid_selector?(selector)
      raise Exception.new, "valid_selector? should be overridden in subclass of AbstractRecurringTodosBuilder"
    end

    private

    def tag_list_or_empty_string(attributes)
      # avoid nil
      attributes.get(:tag_list).blank? ? "" : attributes.get(:tag_list).strip
    end

  end

end 