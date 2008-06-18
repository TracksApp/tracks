# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080617044632) do

  create_table "contexts", :force => true do |t|
    t.string   "name",                     :default => "",    :null => false
    t.integer  "position",   :limit => 11
    t.boolean  "hide",                     :default => false
    t.integer  "user_id",    :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contexts", ["user_id"], :name => "index_contexts_on_user_id"
  add_index "contexts", ["user_id", "name"], :name => "index_contexts_on_user_id_and_name"

  create_table "notes", :force => true do |t|
    t.integer  "user_id",    :limit => 11, :null => false
    t.integer  "project_id", :limit => 11, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["project_id"], :name => "index_notes_on_project_id"
  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued",     :limit => 11
    t.integer "lifetime",   :limit => 11
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created", :limit => 11
  end

  create_table "open_id_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "preferences", :force => true do |t|
    t.integer "user_id",                            :limit => 11,                                             :null => false
    t.string  "date_format",                        :limit => 40, :default => "%d/%m/%Y",                     :null => false
    t.integer "week_starts",                        :limit => 11, :default => 0,                              :null => false
    t.integer "show_number_completed",              :limit => 11, :default => 5,                              :null => false
    t.integer "staleness_starts",                   :limit => 11, :default => 7,                              :null => false
    t.boolean "show_completed_projects_in_sidebar",               :default => true,                           :null => false
    t.boolean "show_hidden_contexts_in_sidebar",                  :default => true,                           :null => false
    t.integer "due_style",                          :limit => 11, :default => 0,                              :null => false
    t.string  "admin_email",                                      :default => "butshesagirl@rousette.org.uk", :null => false
    t.integer "refresh",                            :limit => 11, :default => 0,                              :null => false
    t.boolean "verbose_action_descriptors",                       :default => false,                          :null => false
    t.boolean "show_hidden_projects_in_sidebar",                  :default => true,                           :null => false
    t.string  "time_zone",                                        :default => "London",                       :null => false
    t.boolean "show_project_on_todo_done",                        :default => false,                          :null => false
    t.string  "title_date_format",                                :default => "%A, %d %B %Y",                 :null => false
    t.integer "mobile_todos_per_page",              :limit => 11, :default => 6,                              :null => false
  end

  add_index "preferences", ["user_id"], :name => "index_preferences_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name",                             :default => "",       :null => false
    t.integer  "position",           :limit => 11
    t.integer  "user_id",            :limit => 11, :default => 1
    t.text     "description"
    t.string   "state",              :limit => 20, :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_context_id", :limit => 11
    t.datetime "completed_at"
  end

  add_index "projects", ["user_id"], :name => "index_projects_on_user_id"
  add_index "projects", ["user_id", "name"], :name => "index_projects_on_user_id_and_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id",   :limit => 11
    t.integer "tag_id",        :limit => 11
    t.string  "taggable_type"
    t.integer "user_id",       :limit => 11
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "todos", :force => true do |t|
    t.integer  "context_id",   :limit => 11,                          :null => false
    t.integer  "project_id",   :limit => 11
    t.string   "description",                :default => "",          :null => false
    t.text     "notes"
    t.datetime "created_at"
    t.date     "due"
    t.datetime "completed_at"
    t.integer  "user_id",      :limit => 11, :default => 1
    t.date     "show_from"
    t.string   "state",        :limit => 20, :default => "immediate", :null => false
  end

  add_index "todos", ["user_id", "state"], :name => "index_todos_on_user_id_and_state"
  add_index "todos", ["user_id", "project_id"], :name => "index_todos_on_user_id_and_project_id"
  add_index "todos", ["project_id"], :name => "index_todos_on_project_id"
  add_index "todos", ["context_id"], :name => "index_todos_on_context_id"
  add_index "todos", ["user_id", "context_id"], :name => "index_todos_on_user_id_and_context_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 80, :default => "",         :null => false
    t.string   "crypted_password",          :limit => 40
    t.string   "token"
    t.boolean  "is_admin",                                :default => false,      :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "auth_type",                               :default => "database", :null => false
    t.string   "open_id_url"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
