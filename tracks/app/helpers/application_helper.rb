# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Convert a date object to the format specified
	# in config/settings.yml
	#
  def format_date(date)
		date_fmt = app_configurations["formats"]["date"]
		formatted_date = date.strftime("#{date_fmt}")
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
end
