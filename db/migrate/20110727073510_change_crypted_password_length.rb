class ChangeCryptedPasswordLength < ActiveRecord::Migration
  def self.up
    change_column 'users', 'crypted_password', :string, :limit => 60
  end

  def self.down
    # Begin with setting all passwords hashed with BCrypt to SHA-1 ones as
    # BCrypt's format won't fit into a narrower column.
    User.transaction do
      User.all.each do |user|
        if user.auth_type == 'database' and not user.uses_deprecated_password?
          user.password = user.password_confirmation = nil
          user.crypted_password = User.sha1 'change_me'
          user.save!
        end
      end
    end
    change_column 'users', 'crypted_password', :string, :limit => 40
  end
end
