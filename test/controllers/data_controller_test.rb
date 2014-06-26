require 'test_helper'

class DataControllerTest < ActionController::TestCase

  def setup
  end

  def test_csv_export_completes_without_error
    login_as :admin_user
    get :csv_notes
  end

  def test_yml_export_comleted_without_error
    login_as :admin_user
    get :yaml_export
  end
end
