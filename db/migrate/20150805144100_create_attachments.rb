class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.references :todo, index: true
      t.attachment :file
      t.timestamps
    end
  end
end
