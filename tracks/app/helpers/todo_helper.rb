module TodoHelper
  

  def display_done(ary,context)
  	result_string = ""
		result_string << "<ul>" 
  	ary.each do |@item|
    	result_string << "<li>" + @item.description + " " 

				# Item should have a completion date if it is done
				# This is just a sanity check
				#
				if @item.completed != nil
					result_string << "[completed: " + format_date(@item.completed) + "]" + " "
				end
		
    	result_string << "in " + @item.context['name'].capitalize + "</li>"
  	end
		result_string << "</ul>"
  	return result_string
	end
	
	
	def count_items(items, context)
	  # Count the number of items in the selected context
	  #
	  count = 0
	  for item in items
	    if item.context['name'] == context
	      count += 1
	    end
	  end
	  return count
	end
	
end
