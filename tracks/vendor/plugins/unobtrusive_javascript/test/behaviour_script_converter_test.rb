require File.dirname(__FILE__) + '/test_helper'

class DefaultBehaviourScriptConversionTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @output = UJS::BehaviourScriptConverter.convert_to_hash(@script)
  end
  
  def test_should_have_no_rules_and_the_correct_default_options
    assert_equal({ :options => { :cache => false, :reapply_after_ajax => true },
                   :rules => [] }, @output)
  end
end

class EmptyBehaviourScriptWithDifferentOptionsConversionTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new(true, false)
    @output = UJS::BehaviourScriptConverter.convert_to_hash(@script)
  end
  
  def test_should_have_no_rules_and_the_correct_options
    assert_equal({ :options => { :cache => true, :reapply_after_ajax => false },
                   :rules => [] }, @output)
  end
end

class BehaviourScriptWithOneRuleConversionTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule('div.foo:click', 'alert("TEST")')
    @output = UJS::BehaviourScriptConverter.convert_to_hash(@script)
  end
  
  def test_should_have_one_behaviour_and_correct_options
    assert_equal({ :options => { :cache => false, :reapply_after_ajax => true },
                   :rules => [
                     ['div.foo:click', 'alert("TEST")']
                    ] }, @output)
  end
end

class BehaviourScriptWithTwoRuleConversionTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule('div.foo:click', 'alert("TEST")')
    @script.add_rule('div.bar:click', 'alert("TEST 2")')
    @output = UJS::BehaviourScriptConverter.convert_to_hash(@script)
  end
  
  def test_should_have_one_behaviour_and_correct_options
    assert_equal({ :options => { :cache => false, :reapply_after_ajax => true },
                   :rules => [
                     ['div.foo:click', 'alert("TEST")'],
                     ['div.bar:click', 'alert("TEST 2")']
                    ] }, @output)
  end
end

class BehaviourScriptFromHashTest < Test::Unit::TestCase
  def setup
    @script = UJS::BehaviourScript.new
    @script.add_rule('div.foo:click', 'alert("TEST")')
    @script.add_rule('div.bar:click', 'alert("TEST 2")')
    @converted_script = UJS::BehaviourScriptConverter.convert_from_hash(@script.to_hash)
  end
  
  def test_should_equal_the_script_it_was_converted_from_in_the_first_place
    assert_equal @script.cache?, @converted_script.cache?
    assert_equal @script.reapply_after_ajax?, @converted_script.reapply_after_ajax?
    assert_equal @script.rules, @converted_script.rules
  end
end