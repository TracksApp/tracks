require File.dirname(__FILE__) + '/test_helper'
require 'ujs/behaviour_script'

class NewBehaviourScriptTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
  end
  
  def test_should_render_nothing_on_to_string
    assert_equal "", @script.to_s
  end
  
  def test_should_not_be_cached
    assert !@script.cache?
  end
  
  def test_should_be_reapplied_after_an_ajax_request
    assert @script.reapply_after_ajax?
  end
end

class BehaviourScriptWithOneRuleTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule("div.header:click", "alert('Hello World')")
  end
  
  def test_should_render_the_rule_as_a_javascript_event_on_to_s
    expected_js = "Event.addBehavior({\n\"div.header:click\": function(event) {\nalert('Hello World')\n}\n});"
    assert_equal expected_js, @script.to_s
  end
end

class BehaviourScriptWithTwoRulesTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule("div.header:mouseover", "alert('Hello World')")
    @script.add_rule("div.header:mouseout", "alert('Goodbye World')")
  end
  
  def test_should_render_all_rules_as_javascript_events_on_to_s
    expected_js = "Event.addBehavior({\n\"div.header:mouseover\": function(event) {\nalert('Hello World')\n},"
    expected_js = expected_js + "\n\"div.header:mouseout\": function(event) {\nalert('Goodbye World')\n}\n});"
    assert_equal expected_js, @script.to_s
  end
end

class BehaviourScriptWithRuleThatCancelsDefaultTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule("div.header:mouseover", "alert('Hello World');", true)
  end
  
  def test_should_render_rule_with_return_false_appended_on_to_s
    expected_js = "Event.addBehavior({\n\"div.header:mouseover\": function(event) {\nalert('Hello World'); return false;\n}\n});"
    assert_equal expected_js, @script.to_s
  end
end

class BehaviourScriptWithNoRulesTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
  end
  
  def test_should_render_nothing_on_to_s
    assert_equal "", @script.to_s
  end
end

class BehaviourScriptWithRulesSetToNotReapplyAfterAjaxTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.reapply_after_ajax = false
    @script.add_rule("div.header:click", "alert('Hello World')")
  end
  
  def test_should_append_reapply_javascript_to_end_of_rules_javascript_on_to_s
    expected_js = "Event.addBehavior({\n\"div.header:click\": function(event) {\nalert('Hello World')\n}\n});"
    expected_js = expected_js + "\nEvent.addBehavior.reapplyAfterAjax = false;"
    assert_equal expected_js, @script.to_s
  end
end

class BehaviourScriptToHashTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new(true, false)
    @script.add_rule("div.header:mouseover", "alert('Hello World')")
    @script.add_rule("div.header:mouseout", "alert('Goodbye World')")
  end
  
  def test_should_return_converted_behaviour_script
    assert_equal({ :options => { :cache => true, :reapply_after_ajax => false },
                   :rules => [
                     ['div.header:mouseover', "alert('Hello World')"],
                     ['div.header:mouseout', "alert('Goodbye World')"]
                    ] }, @script.to_hash)
  end
end