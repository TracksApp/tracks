#make sure the controller is accessible
$LOAD_PATH << File.dirname(__FILE__)
require 'switch_environment_controller'

#hijack /selenium
module ActionController
  module Routing #:nodoc:
    class RouteSet #:nodoc:
      alias_method :draw_without_selenium_routes, :draw
      def draw
        draw_without_selenium_routes do |map|
          map.connect 'selenium/*filename',
            :controller => 'switch_environment', :action => 'index'
          
          yield map
        end
      end
    end
  end
end
