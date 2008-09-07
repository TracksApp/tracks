class AddSmsToPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :sms_email, :string
    add_column :preferences, :sms_context_id, :integer
  end

  def self.down
    remove_column :preferences, :sms_context_id
    remove_column :preferences, :sms_email
  end
end
