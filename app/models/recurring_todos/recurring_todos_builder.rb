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
        raise Exception.new("Unknown recurrence selector (#{selector})")
      end
    end

    def build
      @builder.build
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
      if project_specified_by_name?
        @project = @user.projects.where(:name => project_name).first
        unless @project
          @project = @user.projects.build(:name => project_name)
          @new_project_created = true
        end
      else
        @project = @attributes['project_id'].present? ? @user.projects.find(@attributes['project_id']) : nil
      end
      @attributes[:project] = @project
    end

    def parse_context
      if context_specified_by_name?
        @context = @user.contexts.where(:name => context_name).first
        unless @context
          @context = @user.contexts.build(:name => context_name)
          @new_context_created = true
        end
      else
        @context = @attributes['context_id'].present? ? @user.contexts.find(@attributes['context_id']) : nil
      end
      @attributes[:context] = @context
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
      @attributes['project_name'].strip unless @attributes['project_name'].nil?
    end

    def context_name
      @attributes['context_name'].strip unless @attributes['context_name'].nil?
    end

  end

end