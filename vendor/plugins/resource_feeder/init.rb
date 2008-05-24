require 'resource_feeder'
ActionController::Base.send(:include, ResourceFeeder::Rss, ResourceFeeder::Atom)