
require 'initializer'

class Rails::Initializer
  def after_initialize_with_autoload
    after_initialize_without_autoload
  
    _logger_debug "has_many_polymorphs: autoload hook invoked"
    Dir["#{RAILS_ROOT}/app/models/**/*.rb"].each do |filename|
      next if filename =~ /svn|CVS|bzr/
      open filename do |file|
        if file.grep(/has_many_polymorphs|acts_as_double_polymorphic_join/).any?
          begin
            model = File.basename(filename)[0..-4].classify
            model.constantize
            _logger_warn "has_many_polymorphs: preloaded parent model #{model}"
          rescue Object => e
            _logger_warn "error preloading #{model}: #{e.inspect}"
          end
        end
      end
    end
  end  
  
  alias_method_chain :after_initialize, :autoload
end
