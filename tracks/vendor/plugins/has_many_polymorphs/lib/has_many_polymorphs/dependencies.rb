
=begin rdoc
Adds a minimal dependency injection framework so that owners of polymorphic relationships reload after their children, reinjecting the child helper methods.

Overrides Dependencies#<tt>new_constants_in</tt>.
=end

module Dependencies
    
  mattr_accessor :injection_graph
  self.injection_graph = Hash.new([])

  # Add a dependency for this target.
  def inject_dependency(target, *requirements)
    target, requirements = target.to_s, requirements.map(&:to_s)    
    injection_graph[target] = ((injection_graph[target] + requirements).uniq - [target])
    requirements.each {|requirement| mark_for_unload requirement }
    _logger_debug "injection graph: #{injection_graph.inspect}" if Dependencies.log_activity
  end

  # Make sure any dependent constants of the constants added by <tt>yield</tt> are reloaded.
  def new_constants_in_with_injection(*descs, &block) # chain

    if Dependencies.log_activity
      _logger_debug "autoloaded constants: #{autoloaded_constants.inspect}"
      _logger_debug "explicitly unloadable constants: #{explicitly_unloadable_constants.inspect}" 
    end
    
    returning(new_constants_in_without_injection(*descs, &block)) do |found|
      _logger_debug "new constants: #{found.inspect}" if Dependencies.log_activity and found.any?
      found.each do |constant|
        injection_graph[constant].each do |requirement| 
          requirement.constantize
           _logger_debug "constantized #{requirement}" if Dependencies.log_activity
        end
      end    
    end
  end
  alias_method_chain :new_constants_in, :injection
   
end
