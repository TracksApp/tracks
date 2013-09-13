class ConvertPreferences < ActiveRecord::Migration

  class User < ActiveRecord::Base; has_one :preference; serialize :preferences; end

  def self.up
    @users = User.all
    @users.each do |user|
      user.create_preference
      user.preference.date_format = user.preferences['date_format']
      user.preference.week_starts = user.preferences['week_starts']
      user.preference.show_number_completed = user.preferences['no_completed']
      user.preference.staleness_starts = user.preferences['staleness_starts']
      user.preference.show_completed_projects_in_sidebar = user.preferences['show_completed_projects_in_sidebar']
      user.preference.show_hidden_contexts_in_sidebar = user.preferences['show_hidden_contexts_in_sidebar']
      user.preference.due_style = user.preferences['due_style']
      user.preference.admin_email = user.preferences['admin_email']
      user.preference.refresh = user.preferences['refresh']
      
      if user.preference.refresh.blank?
        user.preference.refresh = 0
      end
      
      user.preference.save!
    end
    remove_column :users, :preferences
  end

  def self.down
    add_column :users, :preferences, :text
    @users = User.all
    @users.each do |user|
      user.preferences = { "date_format" => "#{user.preference.date_format}",
                            "week_starts" => "#{user.preference.week_starts}",
                            "no_completed" => "#{user.preference.show_number_completed}",
                            "staleness_starts" => "#{user.preference.staleness_starts}",
                            "show_completed_projects_in_sidebar" => "#{user.preference.show_completed_projects_in_sidebar}",
                            "show_hidden_contexts_in_sidebar" => "#{user.preference.show_hidden_contexts_in_sidebar}",
                            "due_style" => "#{user.preference.due_style}",
                            "admin_email" => "#{user.preference.admin_email}",
                            "refresh" => "#{user.preference.refresh}"
                            }
      user.save
    end
  end
end
