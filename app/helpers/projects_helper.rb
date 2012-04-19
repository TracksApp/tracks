module ProjectsHelper

  def get_listing_sortable_options(list_container_id)
    {
      :tag => 'div',
      :handle => 'handle',
      :complete => visual_effect(:highlight, list_container_id),
      :url => order_projects_path
    }
  end

  def set_element_visible(id,test)
    if (test)
      page.show id
    else
      page.hide id
    end
  end

  def project_next_prev
    html = ''
    unless @previous_project.nil?
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << link_to_project(@previous_project, "&laquo; #{project_name}")
    end
    html << ' | ' if @previous_project && @next_project
    unless @next_project.nil?
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << link_to_project(@next_project, "#{project_name} &raquo;")
    end
    html
  end

  def project_next_prev_mobile
    html = '<ul class="next-prev-project">'
    unless @previous_project.nil?
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << '<li class="prev">'
      html << link_to_project_mobile(@previous_project, "5", "#{project_name}")
      html << '</li>'
    end
    unless @next_project.nil?
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << '<li class="next">'
      html << link_to_project_mobile(@next_project, "6", "#{project_name}")
      html << '</li>'
    end
    html << '</ul>'
    html
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
    link_to(descriptor,
      url_for({:controller => 'projects', :action => 'edit', :id => project.id}),
      {
        :id => "link_edit_#{dom_id(project)}",
        :class => "project_edit_settings icon"
      })
  end
  
  def project_summary(project)
    project_description = ''
    project_description += Tracks::Utils.render_text( project.description ) unless project.description.blank?
    project_description += content_tag(:p,
      "#{count_undone_todos_phrase(p)}. " + t('projects.project_state', :state => project.state)
      )
    project_description
  end

  def needsreview_class(item)
    raise "item must be a Project " unless item.kind_of? Project
    return item.needs_review?(current_user) ? "needsreview" : "needsnoreview"
  end

end
