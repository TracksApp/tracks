require File.dirname(__FILE__) + '/../test_helper'

class TodosHelperTest < Test::Rails::HelperTestCase
  fixtures :users

  def setup
    super
  end

  include ActionView::Helpers::DateHelper
  include ApplicationHelper
  include TodosHelper
  
  def current_user
    if @user.nil?
      @user = users(:admin_user)
      class << @user
        def prefs
          Preference.new
        end
      end
    end
    @user
  end

  def format_date(date)
    if date
      date_format = "%d/%m/%Y"
      date.strftime("#{date_format}")
    else
      ''
    end
  end
    
  def test_show_date_in_past
    date = 3.days.ago
    html = show_date(date)
    formatted_date = format_date(date)
    assert_equal %Q{<a title="#{formatted_date}"><span class="red">Scheduled to show 3 days ago</span></a> }, html
  end
  
  def test_show_date_today
    date = Time.zone.now
    html = show_date(date)
    formatted_date = format_date(date)
    assert_equal %Q{<a title="#{formatted_date}"><span class="amber">Show Today</span></a> }, html
  end
  
  def test_show_date_tomorrow
    date = 1.day.from_now
    html = show_date(date)
    formatted_date = format_date(date)
    assert_equal %Q{<a title="#{formatted_date}"><span class="amber">Show Tomorrow</span></a> }, html
  end
  
  def test_show_date_future
    date = 10.days.from_now
    html = show_date(date)
    formatted_date = format_date(date)
    assert_equal %Q{<a title="#{formatted_date}"><span class="green">Show in 10 days</span></a> }, html
  end
  
  def test_remote_star_icon_unstarred
    @todo = flexmock(:id => 1, :to_param => 1, :description => 'Get gas', :starred? => false)
    # added dot (.) to regexp because somehouw the extra dot is added in the tests while its not in the rendered html
    assert_remote_star_icon_helper_matches %r{<a href="/todos/1/toggle_star" class="icon star_item" title="star the action 'Get gas'"><img alt="Blank" class="unstarred_todo" src="/images/blank.png[.?0-9]*" title="Star action" /></a>}
    assert_behavior_registered
  end

  def test_remote_star_icon_starred
    @todo = flexmock(:id => 1, :to_param => 1, :description => 'Get gas', :starred? => true)
    # added dot (.) to regexp because somehouw the extra dot is added in the tests while its not in the rendered html
    assert_remote_star_icon_helper_matches %r{<a href="/todos/1/toggle_star" class="icon star_item" title="star the action 'Get gas'"><img alt="Blank" class="starred_todo" src="/images/blank.png[.?0-9]*" title="Star action" /></a>}
    assert_behavior_registered
  end
  
  def assert_remote_star_icon_helper_matches(regex)
    @controller.send :initialise_js_behaviours #simulate before filter
    output = remote_star_icon
    # puts output
    assert output =~ regex
    @controller.send :store_js_behaviours #simulate after filter
  end
  
  def assert_behavior_registered
    behaviors = @controller.session[:js_behaviours]
    assert behaviors[:options][:reapply_after_ajax]
    assert_equal 1, behaviors[:rules].length
    rule = behaviors[:rules][0]
    assert_equal ".item-container a.star_item:click", rule[0]
    assert_equal "new Ajax.Request(this.href, {asynchronous:true, evalScripts:true, method:'put', parameters:{ _source_view : '' }})\n; return false;",
      rule[1]
  end
  
  def protect_against_forgery?
    false
  end
end
