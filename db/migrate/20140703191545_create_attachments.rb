class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.references :todo, index: true
      t.attachment :file
      t.timestamps
    end
  end
end
