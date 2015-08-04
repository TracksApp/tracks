ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# set config for tests. Overwrite those read from config/site.yml. Use inject to avoid warning about changing CONSTANT
{
  "authentication_schemes" => ["database"],
  "prefered_auth" => "database",
  "email_dispatch" => nil,
  "time_zone" => "Amsterdam"  # force UTC+1 so Travis triggers time zone failures
}.inject( SITE_CONFIG ) { |h, elem| h[elem[0]] = elem[1]; h }

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def setup
    Time.zone = SITE_CONFIG['time_zone']
    @today = Time.zone.now
    @tomorrow = @today + 1.day
    @in_three_days = @today + 3.days
    @in_four_days = @in_three_days + 1.day    # need a day after start_from

    @friday = Time.zone.local(2008,6,6)
    @saturday = Time.zone.local(2008,6,7)
    @sunday = Time.zone.local(2008,6,8)  # june 8, 2008 was a sunday
    @monday = Time.zone.local(2008,6,9)
    @tuesday = Time.zone.local(2008,6,10)
    @wednesday = Time.zone.local(2008,6,11)
    @thursday = Time.zone.local(2008,6,12)
  end

  # Add more helper methods to be used by all tests here...
  def assert_value_changed(object, method = nil)
    initial_value = object.send(method)
    yield
    assert_not_equal initial_value, object.send(method), "#{object}##{method}"
  end
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

  def xml_document
    @xml_document ||= HTML::Document.new(@response.body, false, true)
  end

  def assert_xml_select(*args, &block)
    @html_document = xml_document
    assert_select(*args, &block)
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

  def get_model_class
    @controller.class.to_s.tableize.split("_")[0].camelcase.singularize  #don't ask... converts ContextsController to Context
  end

  def get_class_count
    eval("#{get_model_class}.count")
  end

end

class ActionDispatch::IntegrationTest

  def authenticated_post_xml(url, username, password, parameters, headers = {})
    post url, parameters,
        { 'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
        }.merge(headers)
  end

  def authenticated_get_xml(url, username, password, parameters, headers = {})
    get url, parameters,
        { 'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
          }.merge(headers)
  end

  def assert_response_and_body(type, body, message = nil)
    assert_equal body, @response.body, message
    assert_response type, message
  end

  def assert_response_and_body_matches(type, body_regex, message = nil)
    assert_response type, message
    assert_match body_regex, @response.body, message
  end

  def assert_401_unauthorized
    assert_response_and_body 401, "401 Unauthorized: You are not authorized to interact with Tracks."
  end

  def assert_401_unauthorized_admin
    assert_response_and_body 401, "401 Unauthorized: Only admin users are allowed access to this function."
  end

  def assert_responses_with_error(error_msg)
    assert_response 409
    assert_xml_select 'errors' do
      assert_select 'error', 1, error_msg
    end
  end

end
