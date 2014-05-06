class CalendarController < ApplicationController
  skip_before_filter :login_required, :only => [:show]
  prepend_before_filter :login_or_feed_token_required, :only => [:show]

  def show
    @source_view = 'calendar'
    @page_title = t('todos.calendar_page_title')

    @calendar = Todos::Calendar.new(current_user)
    @projects = @calendar.projects
    @count = current_user.todos.not_completed.are_due.count
    @due_all = current_user.todos.not_completed.are_due.reorder("due")

    respond_to do |format|
      format.html
      format.m {
        cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
      }
      format.ics   {
        render :action => 'show', :layout => false, :content_type => Mime::ICS
      }
      format.xml {
        render :xml => @due_all.to_xml( *todo_xml_params )
      }
    end
  end
end
