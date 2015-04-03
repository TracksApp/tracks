class RemoveRenderedNotes < ActiveRecord::Migration
  def self.up
    remove_column :todos, 'rendered_notes'
  end

  def self.down
    add_column :todos, 'rendered_notes', :text
    
    # Call save on each todo to force generation of rendered_notes
    # Copied from 20120412072508_add_rendered_notes
    say "Rendering todo notes..."
    Todo.all.each{ |todo| todo.save(validate: false) }
    say "Finished rendering todo notes."
  end  
end
