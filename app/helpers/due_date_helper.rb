module DueDateHelper

  class DueDateView
    include ActionView::Context
    include ActionView::Helpers

    COLORS = ['amber','amber','orange','orange','orange','orange','orange','orange']

    def initialize(date, prefs)
      @due = date
      @days = date.nil? ? nil : days_from_today(date)
      @prefs = prefs
    end

    def get_color
      return :red          if @days < 0
      return :green        if @days > 7
      return COLORS[@days]
    end

    def due_text
      case @days
      when 0
        t('todos.next_actions_due_date.due_today')
      when 1
        t('todos.next_actions_due_date.due_tomorrow')
      when 2..7
        if @prefs.due_style == Preference.due_styles[:due_on]
          # TODO: internationalize strftime here
          t('models.preference.due_on', :date => @due.strftime("%A"))
        else
          t('models.preference.due_in', :days => @days)
        end
      else
        # overdue or due very soon! sound the alarm!
        if @days == -1
          t('todos.next_actions_due_date.overdue_by', :days => @days * -1)
        elsif @days < -1
          t('todos.next_actions_due_date.overdue_by_plural', :days => @days * -1)
        else
          # more than a week away - relax
          t('models.preference.due_in', :days => @days)
        end
      end
    end

    def due_date_html
      return "" if @due.nil?
      
      return content_tag(:a, {:title => @prefs.format_date(@due)}) {
              content_tag(:span, {:class => get_color}) { 
                due_text
              }
            }    
    end

    def due_date_mobile_html
      return "" if @due == nil

      return content_tag(:span, {:class => get_color}) {
        @prefs.format_date(@due)
      }
    end     

    private

    def days_from_today(date)
      (date.in_time_zone.to_date - Date.current).to_i
    end

  end

end