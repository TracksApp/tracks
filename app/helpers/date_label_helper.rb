module DateLabelHelper

  class GenericDateView
    include ActionView::Context
    include ActionView::Helpers

    COLORS = {
      :overdue_by_more_than_one => :red,
      :overdue_by_one           => :red,
      :today                    => :amber,
      :tomorrow                 => :amber,
      :this_week                => :orange,
      :more_than_a_week         => :green
    }

    def initialize(date, prefs)
      @date = date
      @days = date.nil? ? nil : days_from_today(date)
      @days_sym = days_to_sym(@days)
      @prefs = prefs
    end

    def get_color
      COLORS[@days_sym]
    end

    def days_from_today(date)
      (date.in_time_zone.to_date - Date.current).to_i
    end

    def days_to_sym(days)
      case days
      when nil
        return nil
      when 0
        return :today
      when 1
        return :tomorrow
      when 2..7
        return :this_week
      else
        if days == -1
          return :overdue_by_one
        elsif days < -1
          return :overdue_by_more_than_one
        else
          return :more_than_a_week
        end
      end
    end

    def date_html_wrapper
      return "" if @date.nil?

      return content_tag(:a, {:title => @prefs.format_date(@date)}) {
              content_tag(:span, {:class => get_color}) {
                yield
              }
            }
    end

    def date_mobile_html_wrapper
      return "" if @date.nil?

      return content_tag(:span, {:class => get_color}) {
        yield
      }
    end

  end

  class DueDateView < GenericDateView

    def due_text
      case @days_sym
      when :overdue_by_one
        t('todos.next_actions_due_date.overdue_by', :days => @days * -1)
      when :overdue_by_more_than_one
        t('todos.next_actions_due_date.overdue_by_plural', :days => @days * -1)
      when :today
        t('todos.next_actions_due_date.due_today')
      when :tomorrow
        t('todos.next_actions_due_date.due_tomorrow')
      when :this_week
        if @prefs.due_style == Preference.due_styles[:due_on]
          # TODO: internationalize strftime here
          t('models.preference.due_on', :date => @date.strftime("%A"))
        else
          t('models.preference.due_in', :days => @days)
        end
      else # should be :more_than_a_week
        t('models.preference.due_in', :days => @days)
      end
    end

    def due_date_html
      date_html_wrapper { due_text }
    end

    def due_date_mobile_html
      date_mobile_html_wrapper { @prefs.format_date(@due) }
    end

  end

  class ShowFromDateView < GenericDateView

    def show_from_text
      case @days_sym
      when :overdue_by_more_than_one, :overdue_by_one
        t('todos.scheduled_overdue', :days => @days * -1)
      when :today
        t('todos.show_today')
      when :tomorrow
        t('todos.show_tomorrow')
      when :this_week
        if @prefs.due_style == Preference.due_styles[:due_on]
          t('todos.show_on_date', :date => @date.strftime("%A"))
        else
          t('todos.show_in_days', :days => @days.to_s)
        end
      else
        t('todos.show_in_days', :days => @days.to_s)
      end
    end

    def show_from_date_html
      date_html_wrapper { show_from_text }
    end

  end

end
