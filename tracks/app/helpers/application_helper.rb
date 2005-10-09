# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Convert a date object to the format specified
  # in config/settings.yml
  #
  def format_date(date)
    if date
      formatted_date = date.strftime("#{ApplicationController::DATE_FORMAT}")
    else
      formatted_date = ''
    end
  end

  # Uses RedCloth to transform text using either Textile or Markdown
  # Need to require redcloth above
  # RedCloth 3.0 or greater is needed to use Markdown, otherwise it only handles Textile
  #
  def markdown(text)
    RedCloth.new(text).to_html
  end

  # Wraps object in HTML tags, tag
  #
  def tag_object(object, tag)
    tagged = "<#{tag}>#{object}</#{tag}>"
  end

  # Converts names to URL-friendly format by substituting underscores for spaces
  #
  def urlize(name)
      name.to_s.gsub(/ /, "_")
  end


  # Check due date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def due_date(due)
    if due == nil
      return ""
    end

    @now = Date.today
    @days = due-@now
       
    case @days
      # overdue or due very soon! sound the alarm!
      when -365..-1
        "<a title='" + format_date(due) + "'><span class=\"red\">Overdue by " + (@days * -1).to_s + " days</span></a> "
      when 0
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Today</span></a> "
      when 1
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
           "<a title='" + format_date(due) + "'><span class=\"orange\">Due in " + @days.to_s + " days</span></a> "
      # more than a week away - relax
      else
        "<a title='" + format_date(due) + "'><span class=\"green\">Due in " + @days.to_s + " days</span></a> "
    end
  end

  # Uses the 'staleness_starts' value from settings.yml (in days) to colour
  # the background of the action appropriately according to the age
  # of the creation date:
  # * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
  # * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
  # * l3: created more than 3 x staleness_starts
  #
  def staleness(item)
    if item.created_at < (ApplicationController::STALENESS_STARTS*3).days.ago
      return "<div class=\"stale_l3\">"
    elsif item.created_at < (ApplicationController::STALENESS_STARTS*2).days.ago
      return "<div class=\"stale_l2\">"
    elsif item.created_at < (ApplicationController::STALENESS_STARTS).days.ago
      return "<div class=\"stale_l1\">"
    else
      return "<div class=\"description\">"
    end
  end

  def calendar_setup( input_field )
    str = "Calendar.setup({ ifFormat:\"#{ApplicationController::DATE_FORMAT}\""
    str << ",firstDay:#{ApplicationController::WEEK_STARTS_ON},showOthers:true,range:[2004, 2010]"
    str << ",step:1,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })"
    javascript_tag str
  end
end
