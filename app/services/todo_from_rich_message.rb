class TodoFromRichMessage

  attr_reader :user, :default_context_id, :description, :notes

  def initialize(user, default_context_id, description, notes)
    @user = user
    @default_context_id = default_context_id
    @description = description
    @notes = notes
  end

  def construct
    extractor   = RichMessageExtractor.new(description)
    description = extractor.description
    context     = extractor.context
    project     = extractor.project

    context_id = default_context_id
    unless context.blank?
      found_context = user.contexts.active.where("name like ?", "%#{context}%").first
      found_context = user.contexts.where("name like ?", "%#{context}%").first if !found_context
      context_id = found_context.id if found_context
    end

    unless user.context_ids.include? context_id
      raise(CannotAccessContext, "Cannot access a context that does not belong to this user.")
    end

    project_id = nil
    unless project.blank?
      if project[0..3].downcase == "new:"
        found_project = user.projects.build
        found_project.name = project[4..259].strip
        found_project.save!
      else
        found_project = user.projects.active.find_by_namepart(project)
        found_project = user.projects.find_by_namepart(project) if found_project.nil?
      end
      project_id = found_project.id unless found_project.nil?
    end

    todo = user.todos.build
    todo.description = description
    todo.raw_notes = notes
    todo.context_id = context_id
    todo.project_id = project_id unless project_id.nil?
    todo
  end
end
