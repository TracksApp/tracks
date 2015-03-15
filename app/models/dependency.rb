class Dependency < ActiveRecord::Base

  # touch to make sure todo caches for predecessor and successor are invalidated

  belongs_to :predecessor, :foreign_key => 'predecessor_id', :class_name => 'Todo', :touch => true
  belongs_to :successor,   :foreign_key => 'successor_id',   :class_name => 'Todo', :touch => true

  validate :check_circular_dependencies

  def check_circular_dependencies
    unless predecessor.nil? or successor.nil?
      errors.add("Depends on:", "Adding '#{successor.specification}' would create a circular dependency") if successor.is_successor?(predecessor)
    end
  end

end

