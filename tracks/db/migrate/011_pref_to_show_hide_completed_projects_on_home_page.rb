class PrefToShowHideCompletedProjectsOnHomePage < ActiveRecord::Migration

  def self.up
    @users = User.find(:all)
    @users.each do |user|
      user.preferences.merge!({"show_completed_projects_on_home_page" => true})
      user.save
    end
  end

  def self.down
  end
end
