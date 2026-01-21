class RemoveDefaultUserid < ActiveRecord::Migration[5.2]
  def change
    change_column_default :contexts, :user_id, nil
    change_column_default :projects, :user_id, nil
    change_column_default :todos, :user_id, nil
    change_column_default :recurring_todos, :user_id, nil
  end
end
