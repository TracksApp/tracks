module TodoHelper
  
	# Counts the number of uncompleted items in the selected context
	#
	def count_items(context)
	  count = Todo.find_all("done=0 AND context_id=#{context.id}").length
	end
	
end
