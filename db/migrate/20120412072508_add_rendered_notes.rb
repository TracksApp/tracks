class AddRenderedNotes < ActiveRecord::Migration
  def self.up
    add_column :todos, 'rendered_notes', :text
    
    puts "-- Clearing show_from dates from completed todos"
    # clear up completed todos that have show_from set. These could have been left over from before the AASM migration
    Todo.completed.find(:all, :conditions =>[ "NOT(show_from IS NULL)"]).each {|t| t.show_from=nil; t.save!}
    puts "-- Generating new column values from notes. This may take a while."
    # Call save! on each todo to force generation of rendered_todos
    i=0; max = Todo.all.count; start = Time.now
    Todo.all.each do |todo|
      todo.save(false)
      i = i + 1
      if i%250==0
        elapsed_sec = (Time.now-start)
        remaining = (elapsed_sec / i)*(max-i)
        puts "Progress: #{i} / #{max} (#{(i.to_f/max.to_f*100.0).floor}%) ETA=#{remaining.floor}s"
      end
    end
    puts "Done: #{i} / #{max}"
  end

  def self.down
    remove_column :todos, 'rendered_notes'
  end
end
