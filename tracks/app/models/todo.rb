class Todo < ActiveRecord::Base
    	
  belongs_to :context, :order => 'name'
	belongs_to :project
	
	# Description field can't be empty, and must be < 100 bytes
	# Notes must be < 60,000 bytes (65,000 actually, but I'm being cautious)
	validates_presence_of :description, :message => "no description provided"
	validates_length_of :description, :maximum => 100, :message => "description is too long"
	validates_length_of :notes, :maximum => 60000, :message => "notes are too long"
	
	# Add a creation date (Ruby object format) to item before it's saved
	# if there is no existing creation date (this prevents creation date
	# being reset to completion date when item is completed)
	#
	def before_save
		if self.created == nil
			self.created = Time.now()
		end
		
		if self.done == 1
		  self.completed = Time.now()
		end
	end
	

end
