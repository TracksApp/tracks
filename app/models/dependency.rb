class Dependency < ActiveRecord::Base

  belongs_to :todo, 
    :class_name => "Todo", :foreign_key => "todo_id"
  belongs_to :predecessor, 
    :class_name => "Todo", :foreign_key => "predecessor_id"
  
end

