class Sidebar
  attr_reader :contexts, :projects

  def initialize(user)
    user = user
    @contexts = user.contexts
    @projects = user.projects
  end

  def active_contexts
    @active_contexts ||= contexts.active
  end

  def hidden_contexts
    @hidden_contexts ||= contexts.hidden
  end

  def active_projects
    @active_projects ||= projects.active
  end

  def hidden_projects
    @hidden_projects ||= projects.hidden
  end

  def completed_projects
    @completed_projects ||= projects.completed
  end
end
