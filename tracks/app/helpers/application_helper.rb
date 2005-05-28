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

  def urlize(name)
      name.to_s.gsub(/ /, "_").downcase
  end
	
	
	# Check due date in comparison to today's date
	# Flag up date appropriately with a 'traffic light' colour code
	#
	# Use 2.days.until?
	def due_date(due)
		if due == nil
			return ""
		end
		
		@now = Date.today
		@days = due-@now
		case @days
  		# overdue or due very soon! sound the alarm!
  		when -365..1
  			"<span class=\"red\">" + format_date(due) + "</span> "
  		# due 2-7 days away
  		when 2..7
  			"<span class=\"amber\">" + format_date(due) + "</span> "
  		# more than a week away - relax
  		else
  			"<span class=\"green\">" + format_date(due) + "</span> "
		end
	end
	
	# Uses the 'staleness_starts' value from settings.yml (in days) to colour
	# the background of the action appropriately according to the age
	# of the creation date:
	# * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
	# * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
	# * l3: created more than 3 x staleness_starts
	#
	def staleness(created)
	  if created < (ApplicationController::STALENESS_STARTS*3).days.ago
	    return "<div class=\"stale_l3\">"
	  elsif created < (ApplicationController::STALENESS_STARTS*2).days.ago
	    return "<div class=\"stale_l2\">"
	  elsif created < (ApplicationController::STALENESS_STARTS).days.ago
	    return "<div class=\"stale_l1\">"
	  else
	    return "<div class=\"description\">"
	  end
	end

end
