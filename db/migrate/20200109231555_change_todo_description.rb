class ChangeTodoDescription < ActiveRecord::Migration[5.2]
  def up 
    change_table :todos do |t|
      t.change :description, :text
    end
  end
  def down
    change_table :todos do |t|
      t.change :description, :string
    end
  end
end
