module Tracks
  module Acts #:nodoc:
    module NamepartFinder #:nodoc:
      
      # This act provides the capabilities for finding a name that equals or starts with a given string
      
      def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
      
      module ActMacro
        def acts_as_namepart_finder
          self.extend(ClassMethods)
        end
      end
      
      module ClassMethods
        
        def find_by_namepart(namepart)
          entity = find(:first, :conditions => ['name = ?', namepart])
          if (entity.nil?)
            entity = find :first, :conditions => ["name LIKE ?", namepart + '%']
          end
          entity
        end
      end
              
    end
  end
end
