require 'action_view/helpers/asset_tag_helper'
require File.dirname(__FILE__) + "/lib/action_view/helpers/swf_fu_helper"
require File.dirname(__FILE__) + "/lib/action_view/helpers/asset_tag_helper/swf_asset"

# ActionView::Helpers is for recent rails version, ActionView::Base for older ones (in which case ActionView::Helpers::AssetTagHelper is also needed for tests...)
ActionView::Helpers.class_eval  { include ActionView::Helpers::SwfFuHelper } # For recent rails version...
ActionView::Base.class_eval     { include ActionView::Helpers::SwfFuHelper } # ...and for older ones
ActionView::TestCase.class_eval { include ActionView::Helpers::SwfFuHelper } if defined? ActionView::TestCase # ...for tests in older versions

ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'swfobject'