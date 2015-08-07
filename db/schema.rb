# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150805144100) do

  create_table "attachments", force: true do |t|
    t.integer  "todo_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["todo_id"], name: "index_attachments_on_todo_id", using: :btree

  create_table "contexts", force: true do |t|
    t.string   "name",                                     null: false
    t.integer  "position",              default: 0
    t.integer  "user_id",               default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",      limit: 20, default: "active", null: false
  end

  add_index "contexts", ["user_id", "name"], name: "index_contexts_on_user_id_and_name", using: :btree
  add_index "contexts", ["user_id"], name: "index_contexts_on_user_id", using: :btree

  create_table "dependencies", force: true do |t|
    t.integer "successor_id",      null: false
    t.integer "predecessor_id",    null: false
    t.string  "relationship_type"
  end

  add_index "dependencies", ["predecessor_id"], name: "index_dependencies_on_predecessor_id", using: :btree
  add_index "dependencies", ["successor_id"], name: "index_dependencies_on_successor_id", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["project_id"], name: "index_notes_on_project_id", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "open_id_authentication_associations", force: true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", force: true do |t|
    t.integer "timestamp",  null: false
    t.string  "server_url"
    t.string  "salt",       null: false
  end

  create_table "preferences", force: true do |t|
    t.integer "user_id",                                                                null: false
    t.string  "date_format",                        limit: 40, default: "%d/%m/%Y",     null: false
    t.integer "week_starts",                                   default: 0,              null: false
    t.integer "show_number_completed",                         default: 5,              null: false
    t.integer "staleness_starts",                              default: 7,              null: false
    t.boolean "show_completed_projects_in_sidebar",            default: true,           null: false
    t.boolean "show_hidden_contexts_in_sidebar",               default: true,           null: false
    t.integer "due_style",                                     default: 0,              null: false
    t.integer "refresh",                                       default: 0,              null: false
    t.boolean "verbose_action_descriptors",                    default: false,          null: false
    t.boolean "show_hidden_projects_in_sidebar",               default: true,           null: false
    t.string  "time_zone",                                     default: "London",       null: false
    t.boolean "show_project_on_todo_done",                     default: false,          null: false
    t.string  "title_date_format",                             default: "%A, %d %B %Y", null: false
    t.integer "mobile_todos_per_page",                         default: 6,              null: false
    t.string  "sms_email"
    t.integer "sms_context_id"
    t.string  "locale"
    t.integer "review_period",                                 default: 14,             null: false
  end

  add_index "preferences", ["user_id"], name: "index_preferences_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                                            null: false
    t.integer  "position",                            default: 0
    t.integer  "user_id",                             default: 1
    t.text     "description",        limit: 16777215
    t.string   "state",              limit: 20,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_context_id"
    t.datetime "completed_at"
    t.string   "default_tags"
    t.datetime "last_reviewed"
  end

  add_index "projects", ["state"], name: "index_projects_on_state", using: :btree
  add_index "projects", ["user_id", "name"], name: "index_projects_on_user_id_and_name", using: :btree
  add_index "projects", ["user_id", "state"], name: "index_projects_on_user_id_and_state", using: :btree
  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "recurring_todos", force: true do |t|
    t.integer  "user_id",                                default: 1
    t.integer  "context_id",                                             null: false
    t.integer  "project_id"
    t.string   "description",                                            null: false
    t.text     "notes",                 limit: 16777215
    t.string   "state",                 limit: 20,                       null: false
    t.datetime "start_from"
    t.string   "ends_on"
    t.datetime "end_date"
    t.integer  "number_of_occurrences"
    t.integer  "occurrences_count",                      default: 0
    t.string   "target"
    t.integer  "show_from_delta"
    t.string   "recurring_period"
    t.integer  "recurrence_selector"
    t.integer  "every_other1"
    t.integer  "every_other2"
    t.integer  "every_other3"
    t.string   "every_day"
    t.boolean  "only_work_days",                         default: false
    t.integer  "every_count"
    t.integer  "weekday"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_always"
  end

  add_index "recurring_todos", ["state"], name: "index_recurring_todos_on_state", using: :btree
  add_index "recurring_todos", ["user_id"], name: "index_recurring_todos_on_user_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "sessions_session_id_index", using: :btree

  create_table "taggings", force: true do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "todos", force: true do |t|
    t.integer  "context_id",                                     null: false
    t.integer  "project_id"
    t.string   "description",                                    null: false
    t.text     "notes",             limit: 16777215
    t.datetime "created_at"
    t.datetime "due"
    t.datetime "completed_at"
    t.integer  "user_id",                            default: 1
    t.datetime "show_from"
    t.string   "state",             limit: 20,                   null: false
    t.integer  "recurring_todo_id"
    t.datetime "updated_at"
    t.text     "rendered_notes",    limit: 16777215
  end

  add_index "todos", ["context_id"], name: "index_todos_on_context_id", using: :btree
  add_index "todos", ["project_id"], name: "index_todos_on_project_id", using: :btree
  add_index "todos", ["state"], name: "index_todos_on_state", using: :btree
  add_index "todos", ["user_id", "context_id"], name: "index_todos_on_user_id_and_context_id", using: :btree
  add_index "todos", ["user_id", "project_id"], name: "index_todos_on_user_id_and_project_id", using: :btree
  add_index "todos", ["user_id", "state"], name: "index_todos_on_user_id_and_state", using: :btree

  create_table "tolk_locales", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], name: "index_tolk_locales_on_name", unique: true, using: :btree

  create_table "tolk_phrases", force: true do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", force: true do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "login",                     limit: 80,                      null: false
    t.string   "crypted_password",          limit: 60
    t.string   "token"
    t.boolean  "is_admin",                             default: false,      null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "auth_type",                            default: "database", null: false
    t.string   "open_id_url"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], name: "index_users_on_login", using: :btree

end
