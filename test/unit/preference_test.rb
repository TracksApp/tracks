require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PreferenceTest < ActiveSupport::TestCase
  fixtures :users, :preferences

  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @admin_user = User.find(1)
    @other_user = User.find(2)
  end

  def test_time_zone
    assert_equal 'London', @admin_user.preference.time_zone
  end
  
  def test_show_project_on_todo_done
    assert @other_user.preference.show_project_on_todo_done
    assert !@admin_user.preference.show_project_on_todo_done
  end
  
  def test_parse_date
    assert_equal @admin_user.at_midnight(Date.new(2007, 5, 20)).to_s, @admin_user.preference.parse_date('20/5/2007').to_s
  end
  
  def test_parse_date_returns_nil_if_string_is_empty
    assert_nil @admin_user.preference.parse_date('')
  end

  def test_parse_date_returns_nil_if_string_is_nil
    assert_nil @admin_user.preference.parse_date(nil)
  end

end
