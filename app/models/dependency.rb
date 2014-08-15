class Dependency < ActiveRecord::Base

  # touch to make sure todo caches for predecessor and successor are invalidated

  belongs_to :predecessor, :foreign_key => 'predecessor_id', :class_name => 'Todo', :touch => true
  belongs_to :successor,   :foreign_key => 'successor_id',   :class_name => 'Todo', :touch => true

end

