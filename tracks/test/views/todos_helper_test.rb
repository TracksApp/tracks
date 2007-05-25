require File.dirname(__FILE__) + '/../test_helper'

class TodosHelperTest < Test::Rails::HelperTestCase

  def setup
    super
  end

  include TodosHelper
    
  def test_remote_star_icon_unstarred
    @todo = flexmock(:id => 1, :to_param => 1, :description => 'Get gas', :starred? => false)
    assert_remote_star_icon_helper_matches %r{<a href="/todos/1;toggle_star" class="icon star_item" title="star the action 'Get gas'"><img alt="Blank" class="unstarred_todo" src="/images/blank.png[?0-9]*" title="Star action" /></a>}
    assert_behavior_registered
  end

  def test_remote_star_icon_starred
    @todo = flexmock(:id => 1, :to_param => 1, :description => 'Get gas', :starred? => true)
    assert_remote_star_icon_helper_matches %r{<a href="/todos/1;toggle_star" class="icon star_item" title="star the action 'Get gas'"><img alt="Blank" class="starred_todo" src="/images/blank.png[?0-9]*" title="Star action" /></a>}
    assert_behavior_registered
  end
  
  def assert_remote_star_icon_helper_matches(regex)
    @controller.send :initialise_js_behaviours #simulate before filter
    output = remote_star_icon
    #puts output
    assert output =~ regex
    @controller.send :store_js_behaviours #simulate after filter
  end
  
  def assert_behavior_registered
    behaviors = @controller.session[:js_behaviours]
    assert behaviors[:options][:reapply_after_ajax]
    assert_equal 1, behaviors[:rules].length
    rule = behaviors[:rules][0]
    assert_equal ".item-container a.star_item:click", rule[0]
    assert_equal "new Ajax.Request(this.href, {asynchronous:true, evalScripts:true, method:'put', parameters:{ _source_view : '' }}); return false;",
                 rule[1]
  end
end
