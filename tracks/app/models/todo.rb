class Todo < ActiveRecord::Base
    	
  belongs_to :context
	belongs_to :project
	
	def before_save
		# Add a creation date (Ruby object format) to item before it's saved
		# if there is no existing creation date (this prevents creation date
		# being reset to completion date when item is completed)
		#
		if self.created == nil
			self.created = Time.now()
		end
	end
	
end
