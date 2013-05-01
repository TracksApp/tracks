class CalendarController < ApplicationController
  def show
    @source_view = 'calendar'
    @page_title = t('todos.calendar_page_title')

    @calendar = Todos::Calendar.new(current_user)
    @projects = @calendar.projects
    @count = current_user.todos.not_completed.are_due.count
    @due_all = current_user.todos.not_completed.are_due.reorder("due")

    respond_to do |format|
      format.html
      format.ics   {
        render :action => 'calendar', :layout => false, :content_type => Mime::ICS
      }
      format.xml {
        render :xml => @due_all.to_xml( *to_xml_params )
      }
    end
  end
end
