class PrefToShowHideSidebarItems < ActiveRecord::Migration

  class User < ActiveRecord::Base; serialize :preferences; end

  def self.up
    @users = User.all
    @users.each do |user|
      user.preferences.merge!({"show_completed_projects_in_sidebar" => true})
      user.preferences.merge!({"show_hidden_contexts_in_sidebar" => true})
      user.save
    end
  end

  def self.down
    @users = User.all
    @users.each do |user|
      user.preferences.delete("show_completed_projects_in_sidebar")
      user.preferences.delete("show_hidden_contexts_in_sidebar")
      user.save
    end
  end
end
