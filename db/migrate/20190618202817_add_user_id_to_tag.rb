class AddUserIdToTag < ActiveRecord::Migration[5.2]
  def self.up
    add_column :tags, :user_id, :integer

    # Find uses of each tag for both Todos and RecurringTodos to
    # figure out which users use which tags.
    @tags = exec_query <<-EOQ
      SELECT t.id AS tid, tds.user_id AS todo_uid, rt.user_id AS rtodo_uid
      FROM tags t
      JOIN taggings tgs ON tgs.tag_id = t.id
      LEFT OUTER JOIN todos tds
       ON tgs.taggable_type = 'Todo' AND tds.id = tgs.taggable_id
      LEFT OUTER JOIN recurring_todos rt
       ON tgs.taggable_type = 'RecurringTodo' AND rt.id = tgs.taggable_id
      WHERE rt.id IS NOT NULL OR tds.id IS NOT NULL
      GROUP BY t.id, tds.user_id, rt.user_id
    EOQ

    # Map each tag to the users using it.
    @tag_users = {}
    @tags.each do |row|
      uid = (row['todo_uid'] ? row['todo_uid'] : row['rtodo_uid'])
      if not @tag_users[row['tid']]
        @tag_users[row['tid']] = [uid]
      elsif not @tag_users[row['tid']].include? uid
        @tag_users[row['tid']] << uid
      end
    end

    # Go through the tags assigning users and duplicating as necessary.
    @tag_users.each do |tid, uids|
      tag = Tag.find(tid)

      # One of the users will get the original tag instance, but first
      # duplicate their own copy to all the others.
      extras = uids.length - 1
      extras.times do |n|
        uid = uids[n+1]

        # Create a duplicate of the tag assigned to the user.
        new_tag = tag.dup
        new_tag.user_id = uid
        new_tag.save!

        # Move all the user's regular todos to the new tag.
        execute <<-EOQ
          UPDATE taggings ta
          JOIN todos t
           ON ta.taggable_type = 'Todo' AND t.id = ta.taggable_id
          SET ta.tag_id = #{new_tag.id}
          WHERE t.user_id = #{uid} AND ta.tag_id = #{tid}
        EOQ

        # Move all the user's recurring todos to the new tag.
        execute <<-EOQ
          UPDATE taggings ta
          JOIN recurring_todos t
           ON ta.taggable_type = 'RecurringTodo' AND t.id = ta.taggable_id
          SET ta.tag_id = #{new_tag.id}
          WHERE t.user_id = #{uid} AND ta.tag_id = #{tid}
        EOQ
      end

      tag.user_id = uids[0]
      tag.save!
    end

    # Set all unowned tags to the only user, if there's only one. Otherwise
    # remove them since there's no way of knowing who they belong to.
    if User.all.count == 1
      uid = User.first.id
      execute <<-EOQ
        UPDATE tags
        SET user_id = #{uid}
        WHERE user_id IS NULL
      EOQ
    else
      execute <<-EOQ
        DELETE FROM tags
        WHERE user_id IS NULL
      EOQ
    end
  end
  def self.down
    remove_column :tags, :user_id
  end
end

