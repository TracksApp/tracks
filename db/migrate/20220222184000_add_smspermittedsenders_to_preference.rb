class AddSmspermittedsendersToPreference < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :sms_permitted_senders, :string
  end
end
