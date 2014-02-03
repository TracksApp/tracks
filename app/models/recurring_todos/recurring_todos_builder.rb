module RecurringTodos

  class RecurringTodosBuilder

    attr_reader :builder, :project, :context, :tag_list, :user

    def initialize (user, attributes)
      @user = user
      @attributes = attributes

      parse_dates
      parse_project
      parse_context

      @builder = create_builder(attributes['recurring_period'])
    end

    def create_builder(selector)
      if %w{daily weekly monthly yearly}.include?(selector)
        return eval("RecurringTodos::#{selector.capitalize}RecurringTodosBuilder.new(@user, @attributes)")
      else
        raise Exception.new("Unknown recurrence selector in recurring_period (#{selector})")
      end
    end

    def build
      @builder.build
    end

    def update(recurring_todo)
      @builder.update(recurring_todo)
    end

    def save
      @project.save if @new_project_created
      @context.save if @new_context_created

      return @builder.save
    end

    def saved_recurring_todo
      @builder.saved_recurring_todo
    end

    def recurring_todo
      @builder.recurring_todo
    end

    def attributes
      @builder.attributes
    end

    private

    def parse_dates
      %w{end_date start_from}.each {|date| @attributes[date] = @user.prefs.parse_date(@attributes[date])}
    end

    def parse_project
      @project, @new_project_created = parse(:project, @user.projects, project_name)
    end

    def parse_context
      @context, @new_context_created = parse(:context, @user.contexts, context_name)
    end

    def parse(object_type, relation, name)
      object = nil
      new_object_created = false

      if specified_by_name?(object_type)
        # find or create context or project by given name
        object, new_object_created = find_or_create_by_name(relation, name)
      else
        # find context or project by its id
        object = attribute_with_id_of(object_type).present? ? relation.find(attribute_with_id_of(object_type)) : nil
      end
      @attributes[object_type] = object
      return object, new_object_created
    end

    def attribute_with_id_of(object_type)
      map = { project: 'project_id', context: 'context_id' }
      @attributes[map[object_type]]
    end

    def find_or_create_by_name(relation, name)
      new_object_created = false

      object = relation.where(:name => name).first
      unless object
        object = relation.build(:name => name)
        new_object_created = true
      end
      
      return object, new_object_created
    end      

    def specified_by_name?(object_type)
      self.send("#{object_type}_specified_by_name?")
    end

    def project_specified_by_name?
      return false if @attributes['project_id'].present?
      return false if project_name.blank?
      return false if project_name == 'None'
      true
    end

    def context_specified_by_name?
      return false if @attributes['context_id'].present?
      return false if context_name.blank?
      true
    end

    def project_name
      @attributes['project_name'].try(:strip)
    end

    def context_name
      @attributes['context_name'].try(:strip)
    end

  end

end