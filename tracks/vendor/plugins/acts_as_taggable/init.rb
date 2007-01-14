require 'acts_as_taggable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)

require File.dirname(__FILE__) + '/lib/tagging'
require File.dirname(__FILE__) + '/lib/tag'