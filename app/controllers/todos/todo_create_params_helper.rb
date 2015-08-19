module Todos
  class TodoCreateParamsHelper

    attr_reader :new_project_created, :new_context_created, :attributes

    def initialize(params, user)
      set_params(params)
      filter_attributes(params)
      filter_tags
      filter_starred

      @user = user
      @errors = []

      @new_project_created = find_or_create_group(:project, user.projects, project_name)
      @new_context_created = find_or_create_group(:context, user.contexts, context_name)
    end

    def set_params(params)
      @params = params['request'] || params
    end

    def filter_attributes(params)
      if params[:request]
        @attributes = todo_params(params[:request])
      elsif params[:todo]
        @attributes = todo_params(params)
      end
      @attributes = {} if @attributes.nil?  # make sure there is at least an empty hash
    end

    def filter_tags
      if @attributes[:tags]
        # for single tags, @attributed[:tags] returns a hash. For multiple tags,
        # it with return an array of hashes. Make sure it is always an array of hashes
        @attributes[:tags][:tag] = [@attributes[:tags][:tag]] unless @attributes[:tags][:tag].class == Array
        # the REST api may use <tags> which will collide with tags association, so rename tags to add_tags
        @attributes[:add_tags] = @attributes[:tags]
        @attributes.delete :tags
      end
    end

    def filter_starred
      if @params[:new_todo_starred]
        @attributes["starred"] = (@params[:new_todo_starred]||"").include? "true"
      end
    end

    def show_from
      @attributes['show_from']
    end

    def due
      @attributes['due']
    end

    def project_name
      @params['project_name'].strip unless @params['project_name'].nil?
    end

    def project_id
      @attributes['project_id']
    end

    def context_name
      @params['context_name'].strip unless @params['context_name'].nil?
    end

    def context_id
      @attributes['context_id']
    end

    def tag_list
      @params['tag_list']
    end

    def predecessor_list
      @params['predecessor_list']
    end

    def parse_dates()
      @attributes['show_from'] = @user.prefs.parse_date(show_from)
      @attributes['due'] = @user.prefs.parse_date(due)
      @attributes['due'] ||= ''
    end

    def sequential?
      return @params[:todos_sequential].present? && @params[:todos_sequential]=='true'
    end

    def specified_by_name?(group_type)
      return send("#{group_type}_specified_by_name?")
    end

    def specified_by_id?(group_type)
      group_id = send("#{group_type}_id")
      group_id.present?
    end

    def project_specified_by_name?
      return false if @attributes['project_id'].present?
      return false if project_name.blank?
      true
    end

    def context_specified_by_name?
      return false if @attributes['context_id'].present?
      return false if context_name.blank?
      true
    end

    def add_errors(model)
      @errors.each {|e| model.errors[ e[:attribute] ] = e[:message] }
    end

    private

    def todo_params(params)
      # keep :predecessor_dependencies from being filterd (for XML API).
      # The permit cannot handle multiple precessors
      if params[:todo][:predecessor_dependencies]
        deps = params[:todo][:predecessor_dependencies][:predecessor]
      end

      # accept empty :todo hash
      if params[:todo].empty?
        params[:todo] = {:ignore => true}
      end

      filtered = params.require(:todo).permit(
        :context_id, :project_id, :description, :notes,
        :due, :show_from, :state,
        # XML API
        :tags => [:tag => [:name]],
        :context => [:name],
        :project => [:name])

      # add back :predecessor_dependencies
      filtered[:predecessor_dependencies] = {:predecessor => deps } unless deps.nil?
      filtered
    end

    def find_or_create_group(group_type, set, name)
      return set_id_by_name(group_type, set, name) if specified_by_name?(group_type)
      return set_id_by_id_string(group_type, set, @attributes["#{group_type}_id"]) if specified_by_id?(group_type)
    end

    def set_id_by_name(group_type, set, name)
      group = set.where(:name => name).first_or_create
      @attributes["#{group_type}_id"] = group.id
      return group.new_record_before_save?
    end

    def set_id_by_id_string(group_type, set, id)
      # be aware, this will replace the project_id/context_id (string) in @attributes with the new found id (int)
      @attributes["#{group_type}_id"] = set.find(id).id
      return false
    rescue
      @errors << { :attribute => group_type, :message => "unknown"}
    end

  end
end
