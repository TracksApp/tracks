
module Dependencies
  
  #### dependency injection

  mattr_accessor :injection_graph
  self.injection_graph = Hash.new([])

  def inject_dependency(target, *requirements)
    target, requirements = target.to_s, requirements.map(&:to_s)    
    injection_graph[target] = ((injection_graph[target] + requirements).uniq - [target])
    requirements.each {|requirement| mark_for_unload requirement }
#    _logger_debug "has_many_polymorphs: injection graph: #{injection_graph.inspect}"
  end

  def new_constants_in_with_injection(*descs, &block) # chain
#    _logger_debug "has_many_polymorphs: NEW: autoloaded constants: #{autoloaded_constants.inspect}; #{explicitly_unloadable_constants.inspect}" if (autoloaded_constants + explicitly_unloadable_constants).any?
    returning(new_constants_in_without_injection(*descs, &block)) do |found|
#      _logger_debug "has_many_polymorphs: new constants: #{found.inspect}" if found.any?
      found.each do |constant|
        injection_graph[constant].each do |requirement| 
          requirement.constantize
 #          _logger_debug "has_many_polymorphs: constantized #{requirement}"
        end
      end    
    end
  end
  alias_method_chain :new_constants_in, :injection
   
end
