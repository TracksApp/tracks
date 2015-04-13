class ProjectFromTodo
  attr_reader :todo

  def initialize(todo)
    @todo = todo
  end

  def create
    project = build_project

    if project.valid?
      todo.destroy
      project.save!
    end

    project
  end

  def build_project
    project = Project.new.tap do |p|
      p.name = todo.description
      p.description = todo.notes
      p.default_context = todo.context
      p.default_tags = todo.tag_list
      p.user = todo.user
    end
  end
end
