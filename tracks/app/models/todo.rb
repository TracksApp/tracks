class Todo < ActiveRecord::Base
    	
  belongs_to :context
	belongs_to :project
	
	# Description field can't be empty, and must be < 100 bytes
	# Notes must be < 60,000 bytes (65,000 actually, but I'm being cautious)
	validates_presence_of :description, :message => "no description provided"
	validates_length_of :description, :maximum => 100, :message => "description is too long"
	validates_length_of :notes, :maximum => 60000, :message => "notes are too long"
	#validates_format_of :due, :with => /^[\d]{2,2}\/[\d]{2,2}\/[\d]{4,4}$/, :message => "date format incorrect"
	
	
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
