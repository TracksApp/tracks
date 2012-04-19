ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_value_changed(object, method = nil)
    initial_value = object.send(method)
    yield
    assert_not_equal initial_value, object.send(method), "#{object}##{method}"
  end
end

module Tracks
  class Config
    def self.salt
      "change-me"
    end
    def self.auth_schemes
      return ["database","open_id"]
    end
  end
end

class ActionController::TestCase
  def login_as(user)
    @request.session['user_id'] = user ? users(user).id : nil
  end
  
  def assert_ajax_create_increments_count(name)
    assert_count_after_ajax_create(name, get_class_count + 1)
  end
  
  def assert_ajax_create_does_not_increment_count(name)
    assert_count_after_ajax_create(name, get_class_count)
  end
  
  def assert_count_after_ajax_create(name, expected_count)
    ajax_create(name)
    assert_equal(expected_count, get_class_count)
  end
  
  def ajax_create(name)
    xhr :post, :create, get_model_class.downcase => {:name => name}
  end
  
  def assert_xml_select(*args, &block)
    @html_document = xml_document
    assert_select(*args, &block)
  end
  
  private
  
  def xml_document
    @xml_document ||= HTML::Document.new(@response.body, false, true)
  end
  
  def get_model_class
    @controller.class.to_s.tableize.split("_")[0].camelcase.singularize  #don't ask... converts ContextsController to Context
  end
  
  def get_class_count
    eval("#{get_model_class}.count")
  end
  
end

class ActiveSupport::TestCase

  # Generates a random string of ascii characters (a-z, "1 0")
  # of a given length for testing assignment to fields
  # for validation purposes
  #
  def generate_random_string(length)
    string = ""
    characters = %w(a b c d e f g h i j k l m n o p q r s t u v w z y z 1\ 0)
    length.times do
      pick = characters[rand(26)]
      string << pick
    end
    return string
  end
  
  def assert_equal_dmy(date1, date2)
    assert_equal date1.strftime("%d-%m-%y"), date2.strftime("%d-%m-%y")
  end

end