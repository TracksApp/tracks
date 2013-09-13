class MakeOldRecurringTodosValidate < ActiveRecord::Migration
  def self.up
    RecurringTodo.all.each do |rt|
      # show_always may not be nil
      rt.show_always = false if rt.show_always.nil?
      # start date should be filled
      rt.start_from = rt.created_at if rt.start_from.nil? || rt.start_from.blank?
      rt.save!
    end
  end

  def self.down
    # no down: leave them validatable
  end
end
