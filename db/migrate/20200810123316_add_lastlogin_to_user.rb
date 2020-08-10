class AddLastloginToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_login_at, :datetime
  end
end
