module ProjectsHelper

  def project_next_prev
    html = ""
    if @previous_project
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << link_to_project(@previous_project, "&laquo; #{project_name}".html_safe)
    end
    html << " | " if @previous_project && @next_project
    if @next_project
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << link_to_project(@next_project, "#{project_name} &raquo;".html_safe)
    end
    html.html_safe
  end

  def project_next_prev_mobile
    prev_project,next_project= "", ""
    if @previous_project
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      prev_project = content_tag(:li, link_to_project_mobile(@previous_project, "5", project_name), :class=>"prev")
    end
    if @next_project
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      next_project = content_tag(:li, link_to_project_mobile(@next_project, "6", project_name), :class=>"next")
    end
    return content_tag(:ul, "#{prev_project}#{next_project}".html_safe, :class=>"next-prev-project").html_safe
  end

  def link_to_delete_project(project, descriptor = sanitize(project.name))
    link_to(
      descriptor,
      project_path(project, :format => 'js'),
      {
        :id => "delete_project_#{project.id}",
        :class => "delete_project_button icon",
        :x_confirm_message => t('projects.delete_project_confirmation', :name => project.name),
        :title => t('projects.delete_project_title')
      }
    )
  end

  def link_to_edit_project (project, descriptor = sanitize(project.name))
    link_to(descriptor, edit_project_path(project),
      {
        :id => "link_edit_#{dom_id(project)}",
        :class => "project_edit_settings icon"
      })
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

end
