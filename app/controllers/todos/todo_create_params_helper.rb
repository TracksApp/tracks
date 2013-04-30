module Todos
  class TodoCreateParamsHelper

    attr_reader :new_project_created, :new_context_created, :attributes

    def initialize(params, user)
      @params = params['request'] || params
      @attributes = find_attributes(params)
      @user = user
      @errors = []

      if attributes[:tags]
        # for single tags, @attributed[:tags] returns a hash. For multiple tags,
        # it with return an array of hashes. Make sure it is always an array of hashes
        attributes[:tags][:tag] = [attributes[:tags][:tag]] unless attributes[:tags][:tag].class == Array
        # the REST api may use <tags> which will collide with tags association, so rename tags to add_tags
        attributes[:add_tags] = attributes[:tags]
        attributes.delete :tags
      end

      @new_project_created = find_or_create_group(:project, user.projects, project_name)
      @new_context_created = find_or_create_group(:context, user.contexts, context_name)
      attributes["starred"] = (params[:new_todo_starred]||"").include? "true" if params[:new_todo_starred]
    end

    def find_attributes(params)
      (params['request'] && params['request']['todo']) || params['todo']
    end

    def show_from
      attributes['show_from']
    end

    def due
      attributes['due']
    end

    def project_name
      @project_name ||= @params['project_name'].strip if @params['project_name']
    end

    def project_id
      attributes['project_id']
    end

    def context_name
      @context_name ||= @params['context_name'].strip if @params['context_name']
    end

    def context_id
      attributes['context_id']
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
      return !@params[:todos_sequential].blank? && @params[:todos_sequential]=='true'
    end

    def specified_by_name?(group_type)
      return send("#{group_type}_specified_by_name?")
    end

    def specified_by_id?(group_type)
      group_id = send("#{group_type}_id")
      !group_id.blank?
    end

    def project_specified_by_name?
      return false unless attributes['project_id'].blank?
      return false if project_name.blank?
      return false if project_name == 'None'
      true
    end

    def context_specified_by_name?
      return false unless attributes['context_id'].blank?
      return false if context_name.blank?
      true
    end

    def add_errors(model)
      @errors.each {|e| model.errors[ e[:attribute] ] = e[:message] }
    end

    private

    def find_or_create_group(group_type, set, name)
      return set_id_by_name(group_type, set, name) if specified_by_name?(group_type)
      return set_id_by_id_string(group_type, set, attributes["#{group_type}_id"]) if specified_by_id?(group_type)
    end

    def set_id_by_name(group_type, set, name)
      group = set.where(:name => name).first_or_create
      attributes["#{group_type}_id"] = group.id
      return group.new_record_before_save?
    end

    def set_id_by_id_string(group_type, set, id)
      # be aware, this will replace the project_id/context_id (string) in attributes with the new found id (int)
      attributes["#{group_type}_id"] = set.find(id).id
      return false
    rescue
      @errors << { :attribute => group_type, :message => "unknown"}
    end

  end
end
