$:.unshift(File.dirname(__FILE__) + '/../lib')

require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'rubygems'
require 'breakpoint'

require 'action_controller/test_process'

ActionController::Base.logger = nil
ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

class ArtsController < ActionController::Base
  def alert
    render :update do |page|
      page.alert 'This is an alert'
    end
  end
  
  def assign
    render :update do |page|
      page.assign 'a', '2'
    end
  end
  
  def call
    render :update do |page|
      page.call 'foo', 'bar', 'baz'
    end
  end
  
  def draggable
    render :update do |page|
      page.draggable 'my_image', :revert => true
    end
  end
  
  def drop_receiving
    render :update do |page|
      page.drop_receiving "my_cart", :url => { :controller => "cart", :action => "add" }
    end
  end
    
  def hide
    render :update do |page|
      page.hide 'some_div'
    end
  end
  
  def insert_html
    render :update do |page|
      page.insert_html :bottom, 'content', 'Stuff in the content div'
    end
  end
  
  def redirect
    render :update do |page|
      page.redirect_to :controller => 'sample', :action => 'index'
    end
  end
  
  def remove
    render :update do |page|
      page.remove 'offending_div'
    end
  end
  
  def replace
    render :update do |page|
      page.replace 'person_45', '<div>This replaces person_45</div>'
    end
  end
  
  def replace_html
    render :update do |page|
      page.replace_html 'person_45', 'This goes inside person_45'
    end
  end
  
  def show
    render :update do |page|
      page.show 'post_1', 'post_2', 'post_3'
    end
  end
  
  def sortable
    render :update do |page|
      page.sortable 'sortable_item'
    end
  end
  
  def toggle
    render :update do |page|
      page.toggle "post_1", "post_2", "post_3"
    end
  end
  
  def visual_effect
    render :update do |page|
      page.visual_effect :highlight, "posts", :duration => '1.0'    
    end
  end
  
  def page_with_one_chained_method
    render :update do |page|
      page['some_id'].toggle
    end
  end
  
  def page_with_assignment
    render :update do |page|
      page['some_id'].style.color = 'red'
    end
  end
  
  def rescue_errors(e) raise e end

end

class ArtsTest < Test::Unit::TestCase
  def setup
    @controller = ArtsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_alert
    get :alert
    
    assert_nothing_raised { assert_rjs :alert, 'This is an alert' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :alert, 'This is not an alert'
    end
    
    assert_nothing_raised { assert_no_rjs :alert, 'This is not an alert' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :alert, 'This is an alert' 
    end
  end
  
  def test_assign
    get :assign
    
    assert_nothing_raised { assert_rjs :assign, 'a', '2' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :assign, 'a', '3'
    end
    
    assert_nothing_raised { assert_no_rjs :assign, 'a', '3' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :assign, 'a', '2'
    end
  end
  
  def test_call
    get :call
    
    assert_nothing_raised { assert_rjs :call, 'foo', 'bar', 'baz' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :call, 'foo', 'bar'
    end
    
    assert_nothing_raised { assert_no_rjs :call, 'foo', 'bar' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :call, 'foo', 'bar', 'baz'
    end
  end
  
  def test_draggable
    get :draggable
    
    assert_nothing_raised { assert_rjs :draggable, 'my_image', :revert => true }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :draggable, 'not_my_image'
    end
    
    assert_nothing_raised { assert_no_rjs :draggable, 'not_my_image' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :draggable, 'my_image', :revert => true
    end
  end
  
  def test_drop_receiving
    get :drop_receiving
    
    assert_nothing_raised { assert_rjs :drop_receiving, "my_cart", :url => { :controller => "cart", :action => "add" } }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :drop_receiving, "my_cart"
    end
    
    assert_nothing_raised { assert_no_rjs :drop_receiving, "my_cart" }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :drop_receiving, "my_cart", :url => { :controller => "cart", :action => "add" }
    end
  end
  
  def test_hide
    get :hide
    
    assert_nothing_raised { assert_rjs :hide, 'some_div' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :hide, 'some_other_div'
    end
    
    assert_nothing_raised { assert_no_rjs :hide, 'not_some_div' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :hide, 'some_div'
    end
  end
  
  def test_insert_html
    get :insert_html
    
    
    assert_nothing_raised do
      # No content matching
      assert_rjs :insert_html, :bottom, 'content'
      # Exact content matching
      assert_rjs :insert_html, :bottom, 'content', 'Stuff in the content div'
      # Regex matching
      assert_rjs :insert_html, :bottom, 'content', /in.*content/
      
      assert_no_rjs :insert_html, :bottom, 'not_our_div'
      
      assert_no_rjs :insert_html, :bottom, 'content', /in.*no content/
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_no_rjs :insert_html, :bottom, 'content'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_rjs :insert_html, :bottom, 'no_content'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_no_rjs :insert_html, :bottom, 'content', /in the/
    end
  end
  
  def test_redirect_to
    get :redirect
    
    assert_nothing_raised do
      assert_rjs :redirect_to, :controller => 'sample', :action => 'index'
      assert_no_rjs :redirect_to, :controller => 'sample', :action => 'show'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_rjs :redirect_to, :controller => 'doesnt', :action => 'exist'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_no_rjs :redirect_to, :controller => 'sample', :action => 'index'
    end
  end
  
  def test_remove
    get :remove
    
    assert_nothing_raised do
      assert_rjs :remove, 'offending_div'
      assert_no_rjs :remove, 'dancing_happy_div'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_rjs :remove, 'dancing_happy_div'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do 
      assert_no_rjs :remove, 'offending_div'
    end
  end
  
  def test_replace
    get :replace
    
    assert_nothing_raised do
      # No content matching
      assert_rjs :replace, 'person_45'
      # String content matching
      assert_rjs :replace, 'person_45', '<div>This replaces person_45</div>'
      # regexp content matching
      assert_rjs :replace, 'person_45', /<div>.*person_45.*<\/div>/
      
      assert_no_rjs :replace, 'person_45', '<div>This replaces person_46</div>'
      
      assert_no_rjs :replace, 'person_45', /person_46/
    end
    
    assert_raises(Test::Unit::AssertionFailedError) { assert_no_rjs :replace, 'person_45' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_no_rjs :replace, 'person_45', /person_45/ }
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :replace, 'person_46' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :replace, 'person_45', 'bad stuff' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :replace, 'person_45', /not there/}
  end
  
  def test_replace_html
    get :replace_html
    
    assert_nothing_raised do
      # No content matching
      assert_rjs :replace_html, 'person_45'
      # String content matching
      assert_rjs :replace_html, 'person_45', 'This goes inside person_45'
      # Regexp content matching
      assert_rjs :replace_html, 'person_45', /goes inside/
      
      assert_no_rjs :replace_html, 'person_46'
    
      assert_no_rjs :replace_html, 'person_45', /doesn't go inside/
    end
    
    assert_raises(Test::Unit::AssertionFailedError) { assert_no_rjs :replace_html, 'person_45' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_no_rjs :replace_html, 'person_45', /goes/ }
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :replace_html, 'person_46' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :replace_html, 'person_45', /gos inside/ }
  end
  
  def test_show
    get :show
    assert_nothing_raised do
      assert_rjs :show, "post_1", "post_2", "post_3"
      assert_no_rjs :show, 'post_4'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :show, 'post_4' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :show, "post_1", "post_2", "post_3"
    end
  end
  
  def test_sortable
    get :sortable
    assert_nothing_raised do
      assert_rjs :sortable, 'sortable_item'
      assert_no_rjs :sortable, 'non-sortable-item'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :sortable, 'non-sortable-item' }
    assert_raises(Test::Unit::AssertionFailedError) { assert_no_rjs :sortable, 'sortable_item' }
  end
  
  def test_toggle
    get :toggle
    assert_nothing_raised do
      assert_rjs :toggle, "post_1", "post_2", "post_3"
      assert_no_rjs :toggle, 'post_4'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) { assert_rjs :toggle, 'post_4' }
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :toggle, "post_1", "post_2", "post_3"
    end
  end
  
  def test_visual_effect
    get :visual_effect
    assert_nothing_raised do
      assert_rjs :visual_effect, :highlight, "posts", :duration => '1.0'
      assert_no_rjs :visual_effect, :highlight, "lists"    
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :visual_effect, :highlight, "lists"    
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :visual_effect, :highlight, "posts", :duration => '1.0'
    end
  end
  
  # [] support
  
  def test_page_with_one_chained_method
    get :page_with_one_chained_method
    assert_nothing_raised do
      assert_rjs :page, 'some_id', :toggle
      assert_no_rjs :page, 'some_other_id', :toggle
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_rjs :page, 'some_other_id', :toggle
      assert_no_rjs :page, 'some_id', :toggle
    end
  end
  
  def test_page_with_assignment
    get :page_with_assignment
    
    assert_nothing_raised do
      assert_rjs :page, 'some_id', :style, :color=, 'red'
      assert_no_rjs :page, 'some_id', :color=, 'red'
    end
    
    assert_raises(Test::Unit::AssertionFailedError) do
      assert_no_rjs :page, 'some_id', :style, :color=, 'red'
      assert_rjs :page, 'some_other_id', :style, :color=, 'red'
    end
  end
end
