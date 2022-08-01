require 'test_helper'

class IconHelperTest < ActionView::TestCase
  include IconHelper

  test 'icon_fw generates fixed-width class' do
    assert_equal '<i class="fas fa-gear fa-fw" aria-hidden="true"></i>', icon_fw('fas', 'gear')
  end

  test 'icon_fw accepts an additional class' do
    assert_equal '<i class="fas fa-gear fa-fw myclass" aria-hidden="true"></i>', icon_fw('fas', 'gear', class: 'myclass')
  end
end
