class CreateRecurringTodos < ActiveRecord::Migration
  def self.up
    create_table :recurring_todos do |t|
      # todo data
      t.column :user_id,              :integer,    :default => 1
      t.column :context_id,           :integer,    :null => false
      t.column :project_id,           :integer
      t.column :description,          :string,     :null => false
      t.column :notes,                :text
      t.column :state,                :string, :limit => 20, :default => "active", :null => false
      # running time
      t.column :start_from,           :date
      t.column :ends_on,              :string     # no_end_date, ends_on_number_of_times, ends_on_end_date
      t.column :end_date,             :date       # end_date should be null when 
                                                  # number_of_occurrences is not null
      t.column :number_of_occurences, :integer
      t.column :occurences_count,     :integer, :default => 0  # current count
      # target
      t.column :target,               :string     # 'due_date' or 'show_from'
      t.column :show_from_delta,      :integer    # number of days before due date
      # recurring parameters
      t.column :recurring_period,     :string     # daily, monthly, yearly
      t.column :recurrence_selector,  :integer    # which recurrence is selected
      t.column :every_other1,         :integer    # every 1 day, every 2nd week, 
                                                  # every day 12 of the month
      t.column :every_other2,         :integer    # for month: every 12th of 
                                                  # every 2 (other) month and 
                                                  # year: every 12th of 3 (march)
      t.column :every_other3,         :integer    # for months and years
      t.column :every_day,            :string     # for weekly: 'smtwtfs' for 
                                                  # every week on all days or 
                                                  # ' m w f ' for every week on 
                                                  # every other day
      t.column :only_work_days,       :boolean, :default => false   # for daily
      t.column :every_count,          :integer    # monthly and yearly to describe 
                                                  # the second monday of a month
      t.column :weekday,              :integer    # monthly and yearly to describe
                                                  # day of week for every second 
                                                  # saturday of the month
      t.column :completed_at,         :datetime
      t.timestamps
    end
    
    add_column :todos, :recurring_todo_id, :integer
    
  end

  def self.down
    remove_column :todos, :recurring_todo_id
    drop_table :recurring_todos
  end
end
