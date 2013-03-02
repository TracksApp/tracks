class AddStateToContext < ActiveRecord::Migration

  class Context < ActiveRecord::Base
  end

  def up
    add_column :contexts, :state, :string, :limit => 20, :null => false, :default => 'active'
    Context.reset_column_information
    Context.all.each do |c|
      c.state = c.hide ? 'hidden' : 'active'
      c.save!
    end
    remove_column :contexts, :hide
  end

  def down
    add_column :contexts, :hide, :boolean, :default => false
    Context.reset_column_information
    Context.all.each do |c|
      c.hide = ( c.state == 'hidden' )
      c.save!
    end
    remove_column :contexts, :state
  end
end
