class Dependency < ActiveRecord::Base

  belongs_to :predecessor, :foreign_key => 'predecessor_id', :class_name => 'Todo'
  belongs_to :successor,   :foreign_key => 'successor_id',   :class_name => 'Todo'
  
end

