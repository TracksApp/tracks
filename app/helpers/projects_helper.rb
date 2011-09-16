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
    html = ''
    unless @previous_project.nil?
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << link_to_project_mobile(@previous_project, "5", "&laquo; 5-#{project_name}")
    end
    html << ' | ' if @previous_project && @next_project
    unless @next_project.nil?
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << link_to_project_mobile(@next_project, "6", "6-#{project_name} &raquo;")
    end
    html
  end

  def link_to_delete_project(project, descriptor = sanitize(project.name))
    link_to(
      descriptor,
      project_path(project, :format => 'js'),
      {
        :id => "delete_project_#{project.id}",
        :class => "delete_project_button",
        :x_confirm_message => t('projects.delete_project_confirmation', :name => project.name),
        :title => t('projects.delete_project_title')
      }
    )
  end

  def summary(project)
    project_description = ''
    project_description += sanitize(markdown( project.description )) unless project.description.blank?
    project_description += content_tag(:p, 
      "#{count_undone_todos_phrase(p)}. " + t('projects.project_state', :state => project.state)
      )
    project_description
  end

  def needsreview_class(item)
    ### FIXME: need to check to do this with active projects only
    if item.last_reviewed < current_user.time - (prefs.review_period).days
      return "needsreview"
    else
      return "needsnoreview"
    end
  end


end
