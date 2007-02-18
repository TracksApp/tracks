require File.dirname(__FILE__) + '/../test_helper'

class PreferenceTest < Test::Unit::TestCase
  fixtures :users, :preferences

  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @admin_user = User.find(1)
    @other_user = User.find(2)
  end

  def test_time_zone
    assert_equal 'London', @admin_user.preference.time_zone
    assert_equal @admin_user.preference.tz, TimeZone['London']
  end
  
  def test_show_project_on_todo_done
    assert @other_user.preference.show_project_on_todo_done
    assert !@admin_user.preference.show_project_on_todo_done
  end

end
