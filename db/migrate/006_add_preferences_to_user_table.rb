class AddPreferencesToUserTable < ActiveRecord::Migration
  
  class User < ActiveRecord::Base; end
  
  def self.up
    add_column :users, :preferences, :text
    @users = User.all
    @users.each do |u|
      u.preferences = { "date_format" => "%d/%m/%Y", "week_starts" => "1", "no_completed" => "5", "staleness_starts" => "7", "due_style" => "1", "admin_email" => "butshesagirl@rousette.org.uk"}
      u.save
    end
  end

  def self.down
    remove_column :users, :preferences
  end
end
