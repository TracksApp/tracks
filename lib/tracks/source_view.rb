# Inspiration from Bruce Williams [http://codefluency.com/articles/2006/07/01/rails-views-getting-in-context/]
module Tracks
  
  module SourceViewSwitching
  
    class Responder
      
      def initialize(source_view)
        @source_view = source_view.underscore.gsub(/\s+/,'_').to_sym rescue nil
      end
      
      def nil?
        yield if @source_view.nil? && block_given?
      end

      def context
        yield if :context == @source_view && block_given?
      end
      
      def method_missing(check_source_view,*args)
        yield if check_source_view == @source_view && block_given?
      end
      
    end
  
    module Controller
      
      def self.included(base)
        base.send(:helper, Tracks::SourceViewSwitching::Helper)
        base.send(:helper_method, :source_view)
      end
      
      def source_view_is( s )
        s == (params[:_source_view] || @source_view).to_sym
      end
      
      def source_view_is_one_of( *s )
        s.include?(params[:_source_view].to_sym)
      end
  
      def source_view
        responder = Tracks::SourceViewSwitching::Responder.new(params[:_source_view] || @source_view)
        block_given? ? yield(responder) : responder
      end
          
    end
  
    module Helper
      
      def source_view_tag(name)
        hidden_field_tag :_source_view, name.underscore.gsub(/\s+/,'_')
      end
      
      def source_view_is( s )
        s == (params[:_source_view] || @source_view).to_sym
      end
    
      def source_view_is_one_of( *s )
        s.include?((params[:_source_view] || @source_view).to_sym)
      end

    end
  
  end
  
end

ActionController::Base.send(:include, Tracks::SourceViewSwitching::Controller)
