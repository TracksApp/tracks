class UJS::BehaviourScriptConverter
  def initialize(script)
    @script = script
  end
  
  # Converts a BehaviourScript object into a custom hash format
  def self.convert_to_hash(script)
    self.new(script).to_hash
  end
  
  # Converts a hash-converted BehaviourScript back to a BehaviourScript again
  def self.convert_from_hash(script_hash)
    script = UJS::BehaviourScript.new(script_hash[:options][:cache], script_hash[:options][:reapply_after_ajax])
    script_hash[:rules].each { |r| script.add_rule(r[0], r[1]) }
    script
  end
  
  # Convert behaviour script to a hash
  def to_hash
    { :options => { :cache => @script.cache?, :reapply_after_ajax => @script.reapply_after_ajax? },
      :rules => @script.rules }
  end
end