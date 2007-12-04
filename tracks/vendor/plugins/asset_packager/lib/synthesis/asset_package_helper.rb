module Synthesis
  module AssetPackageHelper
    
    def javascript_include_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      if sources.include?(:defaults) 
        sources = sources[0..(sources.index(:defaults))] + 
          ['prototype', 'effects', 'dragdrop', 'controls'] + 
          (File.exists?("#{RAILS_ROOT}/public/javascripts/application.js") ? ['application'] : []) + 
          sources[(sources.index(:defaults) + 1)..sources.length]
        sources.delete(:defaults)
      end

      sources.collect!{|s| s.to_s}
      sources = if suppress_packaging?
        AssetPackage.sources_from_targets("javascripts", sources)
      else
        AssetPackage.targets_from_sources("javascripts", sources)
      end        
      sources.collect {|source| javascript_include_tag(source, options) }.join("\n")
    end

    def stylesheet_link_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      sources.collect!{|s| s.to_s}
      sources = if suppress_packaging?
        AssetPackage.sources_from_targets("stylesheets", sources)
      else
        AssetPackage.targets_from_sources("stylesheets", sources)
      end

      sources.collect { |source|
        source = stylesheet_path(source)
        tag("link", { "rel" => "Stylesheet", "type" => "text/css", "media" => "screen", "href" => source }.merge(options))
      }.join("\n")    
    end

    private
    
      def suppress_packaging?
        return true if RAILS_ENV == "development"
        return true if SUPPRESS_ASSET_PACKAGER == true rescue nil
        return false
      end
      
      # rewrite compute_public_path to allow us to not include the query string timestamp
      # used by ActionView::Helpers::AssetTagHelper
      def compute_public_path(source, dir, ext, add_asset_id=true)
        source = source.dup
        source << ".#{ext}" if File.extname(source).blank?
        unless source =~ %r{^[-a-z]+://}
          source = "/#{dir}/#{source}" unless source[0] == ?/
          asset_id = rails_asset_id(source)
          source << '?' + asset_id if defined?(RAILS_ROOT) and add_asset_id and not asset_id.blank?
          source = "#{ActionController::Base.asset_host}#{@controller.request.relative_url_root}#{source}"
        end
        source
      end
  
      # rewrite javascript path function to not include query string timestamp
      def javascript_path(source)
        compute_public_path(source, 'javascripts', 'js', false)       
      end

      # rewrite stylesheet path function to not include query string timestamp
      def stylesheet_path(source)
        compute_public_path(source, 'stylesheets', 'css', false)
      end

  end
end