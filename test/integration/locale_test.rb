require 'test_helper'

class LocaleTest < ActionDispatch::IntegrationTest

  fixtures :users

  def test_locale_index
    logs_in_as(users(:other_user_email), 'open')
    @user = User.find(@request.session['user_id'])
    locales = I18n.available_locales.map {|l| l.to_s}
    locales.each do |locale|
      # Set the locale
      @user.preference.locale = locale
      @user.preference.save!
      logs_in_as(users(:other_user_email), 'open')
      get '/'
      assert_response :success
      assert_template "todos/index"
    end
  end

end
