require 'test_helper'

class IconHelperTest < ActionView::TestCase
  include IconHelper

  test 'icon_fw generates fixed-width class' do
    assert_equal '<i class="fa fa-gear fa-fw"></i>', icon_fw('gear')
  end

  test 'icon_fw accepts an additional class' do
    assert_equal '<i class="fa fa-gear fa-fw myclass"></i>', icon_fw('gear', class: 'myclass')
  end
end
