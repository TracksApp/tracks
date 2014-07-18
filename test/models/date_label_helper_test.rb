require 'test_helper'

class DateLabelHelperTest < ActiveSupport::TestCase
  fixtures :todos, :users, :preferences
  # :recurring_todos, , :contexts, , :tags, :taggings, :projects

  def test_days_to_sym
    prefs = users(:other_user).prefs
    today = Date.current
    helper = DateLabelHelper::GenericDateView.new(today, prefs)

    assert_equal :today,                    helper.days_to_sym(0),   "0 equals today"
    assert_equal :tomorrow,                 helper.days_to_sym(1),   "0 equals tomorrow"
    assert_equal :this_week,                helper.days_to_sym(2),   "2 equals this week"
    assert_equal :this_week,                helper.days_to_sym(4),   "4 equals this week"
    assert_equal :this_week,                helper.days_to_sym(7),   "7 equals this week"
    assert_equal :more_than_a_week,         helper.days_to_sym(70),  "70 equals more than one week"
    assert_equal :overdue_by_one,           helper.days_to_sym(-1),  "-1 equals overdue by one day"
    assert_equal :overdue_by_more_than_one, helper.days_to_sym(-10), "-10 equals overdue by one day"
  end

  def test_days_from_today
    prefs = users(:other_user).prefs
    today = Date.current
    helper = DateLabelHelper::GenericDateView.new(today, prefs)

    assert_equal 0,  helper.days_from_today(today.at_midnight)
    assert_equal 0,  helper.days_from_today(today.at_beginning_of_day)
    assert_equal 1,  helper.days_from_today(today+1.day)
    assert_equal 10, helper.days_from_today(today+10.days)
  end

  def def_test_get_color
    prefs = users(:other_user).prefs
    today = Date.current

    helper = DateLabelHelper::GenericDateView.new(today, prefs)
    assert_equal :amber, helper.get_color

    helper = DateLabelHelper::GenericDateView.new(today-1.day, prefs)
    assert_equal :red, helper.get_color

    helper = DateLabelHelper::GenericDateView.new(today-5.days, prefs)
    assert_equal :red, helper.get_color

    helper = DateLabelHelper::GenericDateView.new(today+1.day, prefs)
    assert_equal :amber, helper.get_color

    helper = DateLabelHelper::GenericDateView.new(today+3.day, prefs)
    assert_equal :orange, helper.get_color

    helper = DateLabelHelper::GenericDateView.new(today+1.day, prefs)
    assert_equal :green, helper.get_color
  end

  def test_preferences_used_for_number_of_days
    prefs = users(:other_user).prefs

    travel_to DateTime.new(2014, 7, 1) do
      today = Date.current

      prefs.due_style = Preference.due_styles[:due_on]
      helper = DateLabelHelper::DueDateView.new(today + 3.days, prefs)
      assert_equal "Due on #{(today+3.days).strftime("%A")}", helper.due_text

      prefs.due_style = Preference.due_styles[:due_in_n_days]
      helper = DateLabelHelper::DueDateView.new(today + 3.days, prefs)
      assert_equal "Due in 3 days", helper.due_text

      prefs.due_style = Preference.due_styles[:due_on]
      helper = DateLabelHelper::ShowFromDateView.new(today + 3.days, prefs)
      assert_equal "Show on #{(today+3.days).strftime("%A")}", helper.show_from_text

      prefs.due_style = Preference.due_styles[:due_in_n_days]
      helper = DateLabelHelper::ShowFromDateView.new(today + 3.days, prefs)
      assert_equal "Show in 3 days", helper.show_from_text
    end
  end

  def test_smoke_test_html
    prefs = users(:other_user).prefs
    today = Date.current

    helper = DateLabelHelper::DueDateView.new(today + 3.days, prefs)
    assert !helper.due_date_html.blank?
    assert !helper.due_date_mobile_html.blank?

    helper = DateLabelHelper::DueDateView.new(nil, prefs)
    assert helper.due_date_html.blank?
    assert helper.due_date_mobile_html.blank?


    helper = DateLabelHelper::ShowFromDateView.new(nil, prefs)
    assert helper.show_from_date_html.blank?
  end

end