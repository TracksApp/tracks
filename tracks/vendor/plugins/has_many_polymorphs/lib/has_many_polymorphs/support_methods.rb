
# hope these don't mess anyone up

class String
  def _as_class
    # classify expects self to be plural
    self.classify.constantize
  end
#  def _as_base_class; _as_class.base_class; end
  alias :_singularize :singularize
  alias :_pluralize :pluralize
  alias :_classify :classify
end

class Symbol
  def _as_class; self.to_s._as_class; end
#  def _as_base_class; self.to_s._as_base_class; end
  def _singularize; self.to_s.singularize.to_sym; end
  def _pluralize; self.to_s.pluralize.to_sym; end
  def _classify; self.to_s.classify; end
end

class Array
  def _flatten_once
    self.inject([]){|r, el| r + Array(el)}
  end
end

class Hash    
  def _select
    Hash[*self.select do |key, value|
      yield key, value
    end._flatten_once]
  end
end

class Object
  def _metaclass; (class << self; self; end); end

  def _logger_debug s
    ::ActiveRecord::Base.logger.debug(s) if ::ActiveRecord::Base.logger
  end  
  def _logger_warn s
    if ::ActiveRecord::Base.logger
      ::ActiveRecord::Base.logger.warn(s) 
    else
      $stderr.puts("has_many_polymorphs: #{s}")
    end    
  end
  
end

class ActiveRecord::Base
  def _base_class_name
    self.class.base_class.name.to_s
  end
end
