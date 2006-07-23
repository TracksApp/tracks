class AddUserPrefRefresh < ActiveRecord::Migration
  def self.up
    @users = User.find(:all)
    @users.each do |user|
      user.preferences.merge!({"refresh" => "0"})
      user.save
    end
  end

  def self.down
  end
end
