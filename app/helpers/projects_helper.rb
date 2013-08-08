module ProjectsHelper

  def show_project_name(project)
    if source_view_is :project
      content_tag(:span, :id => "project_name"){project.name}
    else
      link_to_project( project )
    end
  end

  def project_details(project)

    state = {
      "complete" => "projects.was_marked_complete", 
      "hidden"   => "projects.was_marked_hidden", 
      "active"   => "projects.is_active"}

    default_context = project.default_context.nil? ? 
      t('projects.with_no_default_context') :
      t('projects.with_default_context', :context_name => project.default_context.name)

    tags = project.default_tags.blank? ? t('projects.with_no_default_tags') : t('projects.with_default_tags', :tags => project.default_tags)

    created_at = format_date(project.created_at)
    modified_at = format_date(project.updated_at)

    "#{t('projects.this_project')} #{t(state[project.state])} #{default_context} #{tags}." +
    "#{t('projects.this_project')} was created at #{created_at} and last modified at #{modified_at}"
  end

  def project_next_prev
    content_tag(:div, {class: "pagination", id: "project-next-prev"}) do
      content_tag(:small) do 
        content_tag(:ul) do
          html = ""
          html << content_tag(:li) do
            link_to_project(@previous_project, "&laquo; #{@previous_project.shortened_name}".html_safe) 
          end if @previous_project
          html << content_tag(:li) do
            link_to_project(@next_project, "#{@next_project.shortened_name} &raquo;".html_safe) 
          end if @next_project
          html.html_safe
        end
      end
    end
  end

  def project_next_prev_mobile
    prev_project,next_project= "", ""
    prev_project = content_tag(:li, link_to_project_mobile(@previous_project, "5", @previous_project.shortened_name), :class=>"prev") if @previous_project
    next_project = content_tag(:li, link_to_project_mobile(@next_project, "6", @next_project.shortened_name), :class=>"next") if @next_project
    return content_tag(:ul, "#{prev_project}#{next_project}".html_safe, :class=>"next-prev-project")
  end
  
  def project_summary(project)
    project_description = ''
    project_description += Tracks::Utils.render_text( project.description ) unless project.description.blank?
    project_description += content_tag(:p,
      "#{count_undone_todos_phrase(p)}. #{t('projects.project_state', :state => project.state)}".html_safe
      )
  end

  def needsreview_class(item)
    raise "item must be a Project " unless item.kind_of? Project
    return item.needs_review?(current_user) ? "needsreview" : "needsnoreview"
  end

  def link_to_delete_project(project, descriptor = sanitize(project.name))
    link_to_delete(:project, project, descriptor)
  end

  def link_to_edit_project (project, descriptor = sanitize(project.name))
    link_to_edit(:project, project, descriptor).sub!('"',"'")
  end

end
