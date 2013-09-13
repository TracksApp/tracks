class AddUserId < ActiveRecord::Migration
  
  class Project < ActiveRecord::Base; end
  class Context < ActiveRecord::Base; end
  class Todo < ActiveRecord::Base; end
  
  def self.up
    add_column :contexts, :user_id, :integer, :default => 1
    add_column :projects, :user_id, :integer, :default => 1 
    add_column :todos, :user_id, :integer, :default => 1
    Context.all.each { |context| context.user_id = 1 }
    Project.all.each { |project| project.user_id = 1 }
    Todo.all.each { |todo| todo.user_id = 1 }
  end

  def self.down
    remove_column :contexts,   :user_id
    remove_column :projects,   :user_id
    remove_column :todos,      :user_id
  end
end
