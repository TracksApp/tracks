class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
<% attributes.each do |attribute| -%>
      t.column :<%= attribute.name %>, :<%= attribute.type %>
<% end -%>
      t.timestamps
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
