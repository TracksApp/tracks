module RecurringTodos

  class RecurringTodosBuilder

    attr_reader :builder, :project, :context, :tag_list, :user

    def initialize (user, attributes)
      @user = user
      @attributes = Tracks::AttributeHandler.new(@user, attributes)

      parse_dates
      parse_project
      parse_context

      @builder = create_builder(@attributes.get(:recurring_period))
    end

    def create_builder(selector)
      if %w{daily weekly monthly yearly}.include?(selector)
        return eval("RecurringTodos::#{selector.capitalize}RecurringTodosBuilder.new(@user, @attributes)")
      else
        raise Exception.new("Unknown recurrence selector in :recurring_period (#{selector})")
      end
    end

    def build
      @builder.build
    end

    def update(recurring_todo)
      @builder.update(recurring_todo)
    end

    def save
      @builder.save_project if @new_project_created
      @builder.save_context if @new_context_created

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
      %w{end_date start_from}.each {|date| @attributes.parse_date date }
    end

    def parse_project
      @project, @new_project_created = @attributes.parse_collection(:project, @user.projects, @attributes.project_name)
    end

    def parse_context
      @context, @new_context_created = @attributes.parse_collection(:context, @user.contexts, @attributes.context_name)
    end

  end

end