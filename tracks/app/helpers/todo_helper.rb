module TodoHelper
  	
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
