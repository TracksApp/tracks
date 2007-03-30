
# self-referential, polymorphic has_many :through plugin
# http://blog.evanweaver.com/articles/2006/06/02/has_many_polymorphs
# operates via magic dust, and courage

if defined? Rails::Configuration
  class Rails::Configuration
    def has_many_polymorphs_cache_classes= *args
      ::ActiveRecord::Associations::ClassMethods.has_many_polymorphs_cache_classes = *args
    end
  end
end

module ActiveRecord
  
  if ENV['RAILS_ENV'] =~ /development|test/ and ENV['USER'] == 'eweaver'
    # enable this condition to get awesome association debugging
    # you will get a folder "generated_models" in the current dir containing valid Ruby files
    # explaining all ActiveRecord relationships set up by the plugin, as well as listing the 
    # line in the plugin that made each particular macro call
    class << Base
      COLLECTION_METHODS = [:belongs_to, :has_many, :has_and_belongs_to_many, :has_one].each do |method_name|
        alias_method "original_#{method_name}".to_sym, method_name
        undef_method method_name
      end      

      unless defined? GENERATED_CODE_DIR
        # automatic code generation for debugging... bitches
        GENERATED_CODE_DIR = "generated_models"
        system "rm -rf #{GENERATED_CODE_DIR}" 
        Dir.mkdir GENERATED_CODE_DIR

        alias :original_method_missing :method_missing
        def method_missing(method_name, *args, &block)
          if COLLECTION_METHODS.include? method_name.to_sym
            Dir.chdir GENERATED_CODE_DIR do
              filename = "#{ActiveRecord::Associations::ClassMethods.demodulate(self.name.underscore)}.rb"
              contents = File.open(filename).read rescue "\nclass #{self.name}\n\nend\n"
              line = caller[1][/\:(\d+)\:/, 1]
              contents[-5..-5] = "\n  #{method_name} #{args[0..-2].inspect[1..-2]},\n     #{args[-1].inspect[1..-2].gsub(" :", "\n     :").gsub("=>", " => ")}\n#{ block ? "     #{block.inspect.sub(/\@.*\//, '@')}\n" : ""}     # called from line #{line}\n\n"
              File.open(filename, "w") do |file| 
                file.puts contents             
              end
            end
            # doesn't handle blocks
            self.send("original_#{method_name}", *args, &block)
          else
            self.send(:original_method_missing, method_name, *args, &block)
          end
        end
      end
    end
    
    # and we want to track the reloader's shenanigans
    (::Dependencies.log_activity = true) rescue nil
  end
    
  module Associations      
    module ClassMethods
      mattr_accessor :has_many_polymorphs_cache_classes
                  
      def acts_as_double_polymorphic_join opts
        raise RuntimeError, "Couldn't understand #{opts.inspect} options in acts_as_double_polymorphic_join. Please only specify the two relationships and their member classes; there are no options to set.  " unless opts.length == 2

        join_name = self.name.tableize.to_sym
        opts.each do |polymorphs, children|
          parent_hash_key = (opts.keys - [polymorphs]).first # parents are the entries in the _other_ children array
          
          begin
            parent_foreign_key = self.reflect_on_association(parent_hash_key.to_s.singularize.to_sym).primary_key_name
          rescue NoMethodError
            raise RuntimeError, "Couldn't find 'belongs_to' association for :#{parent_hash_key.to_s.singularize} in #{self.name}." unless parent_foreign_key
          end

          parents = opts[parent_hash_key]
          conflicts = (children & parents) # set intersection          
          parents.each do |parent_name| 
 
            parent_class = parent_name.to_s.classify.constantize
            reverse_polymorph = parent_hash_key.to_s.singularize 
            polymorph = polymorphs.to_s.singularize 
             
            parent_class.send(:has_many_polymorphs, 
              polymorphs, {:double => true,
                                 :from => children, 
                                 :as => parent_hash_key.to_s.singularize.to_sym, 
                                 :through => join_name, 
                                 :dependent => :destroy, 
                                 :foreign_key => parent_foreign_key, 
                                 :foreign_type_key => parent_foreign_key.to_s.sub(/_id$/, '_type'),
                                 :reverse_polymorph => reverse_polymorph,
                                 :conflicts => conflicts,
                                 :rename_individual_collections => false})
                                 
            if conflicts.include? parent_name 
              # unify the alternate sides of the conflicting children
              (conflicts).each do |method_name|
                unless parent_class.instance_methods.include?(method_name)
                  parent_class.send(:define_method, method_name) do
                    (self.send("#{reverse_polymorph}_#{method_name}") + 
                     self.send("#{polymorph}_#{method_name}")).freeze
                  end
                end     
              end
              
              # unify the join model
              unless parent_class.instance_methods.include?(join_name)
                parent_class.send(:define_method, join_name) do
                  (self.send("#{join_name}_as_#{reverse_polymorph}") + 
                   self.send("#{join_name}_as_#{polymorph}")).freeze
                end              
              end 
                          
            end                         
          end
        end
      end
          
      def has_many_polymorphs(polymorphs, options, &block)
        options.assert_valid_keys(:from, :acts_as, :as, :through, :foreign_key, :dependent, :double,
                                         :rename_individual_collections, :foreign_type_key, :reverse_polymorph, :conflicts)
            
        # the way this deals with extra parameters to the associations could use some work        
        options[:as] ||= options[:acts_as] ||= self.table_name.singularize.to_sym
        
        # foreign keys follow the table name, not the class name in Rails 2.0
        options[:foreign_key] ||= "#{options[:as].to_s}_id" 
        
        # no conflicts by default
        options[:conflicts] ||= []        

        # construct the join table name
        options[:through] ||= join_table((options[:as].to_s.pluralize or self.table_name), polymorphs)
        if options[:reverse_polymorph]
          options[:through_with_reverse_polymorph] = "#{options[:through]}_as_#{options[:reverse_polymorph]}".to_sym
        else
          options[:through_with_reverse_polymorph] = options[:through]
        end

        options[:join_class_name] ||= options[:through].to_s.classify

        # the class must have_many on the join_table
        opts = {:foreign_key => options[:foreign_key], :dependent => options[:dependent], 
                    :class_name => options[:join_class_name]}
        if options[:foreign_type_key] 
          opts[:conditions] = "#{options[:foreign_type_key]} = #{quote_value self.base_class.name}"
        end
        
        has_many demodulate(options[:through_with_reverse_polymorph]), opts

        polymorph = polymorphs.to_s.singularize.to_sym

        # add the base_class method to the join_table so that STI will work transparently
        inject_before_save_into_join_table(options[:join_class_name], polymorph)    

        # get some reusable info
        children, child_associations = {}, {}
        options[:from].each do |child_plural|
          children[child_plural] = child_plural.to_s.singularize.to_sym
          child_associations[child_plural] = (options[:rename_individual_collections] ? "#{polymorph}_#{child_plural}".to_sym : child_plural)
        end

        # get our models out of the reloadable lists, if requested              
        if self.has_many_polymorphs_cache_classes 
          klasses = [self.name, options[:join_class_name], *children.values.map{|x| x.to_s.classify}]
          klasses += basify_sti_classnames(klasses).keys.to_a.compact.uniq.map{|x| x.to_s.classify}
          klasses.uniq!
          klasses.each {|s| logger.debug "Ejecting #{s.inspect} from the autoload lists"}
          begin
            Dependencies.autoloaded_constants -= klasses
            Dependencies.explicitly_unloadable_constants -= klasses
          rescue NoMethodError
            raise "Rails 1.2.0 or later is required to set config.has_many_polymorphs_cache_classes = true" 
          end
        end

        # auto-inject individually named associations for the children into the join model
        create_virtual_associations_for_join_to_individual_children(children, polymorph, options)

        # iterate through the polymorphic children, running the parent class's :has_many on each one
        create_has_many_through_associations_for_parent_to_children(children, child_associations, polymorphs, polymorph, options)

        # auto-inject the regular polymorphic associations into the child classes
        create_has_many_through_associations_for_children_to_parent(children, polymorph, options)

        create_general_collection_association_for_parent(polymorphs, polymorph, basify_sti_classnames(children), options, &block)
      end

      def self.demodulate(s)
        s.to_s.gsub('/', '_').to_sym
      end
      
    protected

      def demodulate(s)
        ActiveRecord::Associations::ClassMethods.demodulate(s)
      end

      def basify_sti_classnames(hash)
        # this blows
        result = {}
        hash.each do |plural, singular|
          klass = plural.to_s.classify.constantize
          if klass != klass.base_class
            result[klass.base_class.table_name.to_sym] = klass.base_class.table_name.singularize.to_sym
          else
            result[plural] = singular
          end
        end
        result      
      end

      def inject_before_save_into_join_table(join_class_name, polymorph)
        sti_hook = "sti_class_rewrite"
        rewrite_procedure = %[
          self.send(:#{polymorph}_type=, self.#{polymorph}_type.constantize.base_class.name)
        ]
        
        # this also blows, and should be abstracted. alias_method_chain is not enough.
        join_class_name.constantize.class_eval %[          
          unless instance_methods.include? "before_save_with_#{sti_hook}"
            if instance_methods.include? "before_save"                             
              alias_method :before_save_without_#{sti_hook}, :before_save 
              def before_save_with_#{sti_hook}
                before_save_without_#{sti_hook}
                #{rewrite_procedure}
                  end
            else
              def before_save_with_#{sti_hook}
                #{rewrite_procedure}
              end  
            end
            alias_method :before_save, :before_save_with_#{sti_hook}
          end
        ]
        
      end

      def create_virtual_associations_for_join_to_individual_children(children, polymorph, options)
        children.each do |child_plural, child|
          options[:join_class_name].constantize.instance_eval do

            association_name = child.to_s
            association_name += "_as_#{polymorph}" if options[:conflicts].include?(child_plural)
            association = demodulate(association_name)
            
            opts = {:class_name => child.to_s.classify, 
                        :foreign_key => "#{polymorph}_id" }

            unless self.reflect_on_all_associations.map(&:name).include? association
              belongs_to association, opts
            end

          end
        end    
      end
            
      def create_has_many_through_associations_for_children_to_parent(children, polymorph, options)
        children.each do |child_plural, child|

          if child == options[:as]
            raise RuntimeError, "You can't have a self-referential polymorphic has_many :through without renaming the non-polymorphic foreign key in the join model."
          end
          
          parent = self
          child.to_s.classify.constantize.instance_eval do          

            # this shouldn't be called at all during doubles; there is no way to traverse to a
            # double polymorphic parent (XXX is that right?)
            unless options[:double] or options[:conflicts].include? self.name.tableize.to_sym
              begin
                require_dependency parent.name.underscore # XXX why is this here?
              rescue MissingSourceFile  
              end
    
              # the join table
              through = demodulate(options[:through_with_reverse_polymorph]).to_s
              through += "_as_child" if parent == self
              through = through.to_sym

              has_many through, :as => polymorph, 
                                           :class_name => options[:through].to_s.classify, 
                                           :dependent => options[:dependent]
              
              association = options[:as].to_s.pluralize
              association += "_of_#{polymorph.to_s.pluralize}" if options[:rename_individual_collections] # XXX check this
              
              # the polymorphic parent association
              has_many association.to_sym, :through => through,
                                                           :class_name => parent.name,
                                                           :source => options[:as],
                                                           :foreign_key => options[:foreign_key]
            end
                      
          end
        end
      end
      
      def create_has_many_through_associations_for_parent_to_children(children, child_associations, polymorphs, polymorph, options)
        children.each do |child_plural, child|
          #puts ":source => #{child}"
          association = demodulate(child_associations[child_plural]).to_s
          source = demodulate(child).to_s
          
          if options[:conflicts].include? child_plural
            # XXX what?
            association = "#{polymorph}_#{association}" if options[:conflicts].include? self.name.tableize.to_sym
            source +=  "_as_#{polymorph}"
          end        
            
          # activerecord is broken when you try to anonymously extend an association in a namespaced model,
          extension = self.class_eval %[
            module #{association.classify + "AssociationExtension"}
              def push *args
                 proxy_owner.send(:#{polymorphs}).send(:push, *args).select{|x| x.is_a? #{child.to_s.classify}}                  
              end
              alias :<< :push
              def delete *args
                proxy_owner.send(:#{polymorphs}).send(:delete, *args)
              end
              def clear
                proxy_owner.send(:#{polymorphs}).send(:clear, #{child.to_s.classify})
              end
              self # required
            end]            
            
          has_many association.to_sym, :through => demodulate(options[:through_with_reverse_polymorph]), 
             :source => source.to_sym,
             :conditions => ["#{options[:join_class_name].constantize.table_name}.#{polymorph}_type = ?", child.to_s.classify.constantize.base_class.name], 
             :extend => extension
           
        end
      end

      def create_general_collection_association_for_parent(collection_name, polymorph, children, options, &block)
        # we need to explicitly rename all the columns because we are fetching all the children objects at once.
        # if multiple objects have a 'title' column, for instance, there will be a collision and we will potentially
        # lose data.  if we alias the fields and then break them up later, there are no collisions.
        join_model = options[:through].to_s.classify.constantize

        # figure out what fields we wanna grab
        select_fields = []
        children.each do |plural, singular| 
          klass = plural.to_s.classify.constantize
          klass.columns.map(&:name).each do |name|
            select_fields << "#{klass.table_name}.#{name} as #{demodulate plural}_#{name}"
          end
        end

        # now get the join model fields
        join_model.columns.map(&:name).each do |name|
          select_fields << "#{join_model.table_name}.#{name} as #{join_model.table_name}_#{name}"
        end

        from_table  = self.table_name
        left_joins = children.keys.map do |n| 
           klass = n.to_s.classify.constantize
           "LEFT JOIN #{klass.table_name} ON #{join_model.table_name}.#{polymorph}_id = #{klass.table_name}.#{klass.primary_key} AND #{join_model.table_name}.#{polymorph}_type = '#{n.to_s.classify}'"
        end

        sql_query  = 'SELECT ' + select_fields.join(', ') + " FROM #{join_model.table_name}" +
          "\nJOIN #{from_table} as polymorphic_parent ON #{join_model.table_name}.#{options[:foreign_key]} = polymorphic_parent.#{self.primary_key}\n" +
          left_joins.join("\n") + "\nWHERE "
          
          if options[:foreign_type_key]
            sql_query +="#{join_model.table_name}.#{options[:foreign_type_key]} = #{quote_value self.base_class.name} AND "
          end
          
          # for sqlite3 you have to reference the left-most table in WHERE clauses or rows with NULL 
          # join results sometimes get silently dropped. it's stupid.          
          sql_query += "#{join_model.table_name}.#{options[:foreign_key]} "         
          #puts("Built collection property query:\n #{sql_query}")

        class_eval do
          attr_accessor "#{collection_name}_cache"
          cattr_accessor "#{collection_name}_options"

          define_method(collection_name) do
            if collection_name_cache = instance_variable_get("@#{collection_name}_cache")
             #puts("Cache hit on #{collection_name}")
              collection_name_cache
            else
              #puts("Cache miss on #{collection_name}")
              rows = connection.select_all("#{sql_query}" + (new_record? ? "IS NULL" : "= #{self.id}"))
              # this gives us a hash with keys for each object type
              objectified = objectify_polymorphic_array(rows, "#{join_model}", "#{polymorph}_type")
              # locally cache the different object types found
              # this doesn't work... yet.
              objectified.each do |key, array|
                instance_variable_set("@#{ActiveRecord::Associations::ClassMethods.demodulate(key)}", array)
              end
              proxy_object = HasManyPolymorphsProxyCollection.new(objectified[:all], self, send("#{collection_name}_options"))
              (class << proxy_object; self end).send(:class_eval, &block) if block_given?
              instance_variable_set("@#{collection_name}_cache", proxy_object)
            end
          end

          # in order not to break tests, see if we have been defined already
          unless instance_methods.include? "reload_with_#{collection_name}"
            define_method("reload_with_#{collection_name}") do
              send("reload_without_#{collection_name}")
              instance_variable_set("@#{collection_name}_cache",  nil)
              self
            end

            alias_method "reload_without_#{collection_name}", :reload 
            alias_method :reload, "reload_with_#{collection_name}"
          end
        end
                                          
        send("#{collection_name}_options=", 
                      options.merge(:collection_name => collection_name, 
                                    :type_key => "#{polymorph}_type", 
                                    :id_key => "#{polymorph}_id"))
        
#        puts("Defined the collection proxy.\n#{collection_name}\n")
      end

      def join_table(a, b)
        [a.to_s, b.to_s].sort.join("_").to_sym
      end
      
      unless self.respond_to? :quote_value
        # hack it in (very badly) for Rails 1.1.6 people
          def quote_value s
            "'#{s.inspect[1..-2]}'"
          end
      end
            
    end

    ################################################

    # decided to leave this alone unless it becomes clear that there is some benefit
    # in deriving from AssociationProxy
    #
    # the benefit would be custom finders on the collection, perhaps... 
    class HasManyPolymorphsProxyCollection < Array

      alias :array_delete :delete
      alias :array_push :push    
      alias :count :length 

      def initialize(contents, parent, options) 
        @parent = parent
        @options = options
        @join_class = options[:join_class_name].constantize
        return if contents.blank?
        super(contents)
      end              
        
      def push(objs, args={})      
        objs = [objs] unless objs.is_a? Array

        objs.each do |obj|
          data = {@options[:foreign_key] => @parent.id,
                       @options[:type_key] => obj.class.base_class.to_s, @options[:id_key] => obj.id} 
          data.merge!({@options[:foreign_type_key] => @parent.class.base_class.to_s}) if @options[:foreign_type_key] # for double polymorphs
          conditions_string = data.keys.map(&:to_s).push("").join(" = ? AND ")[0..-6]
          if @join_class.find(:first, :conditions => [conditions_string] + data.values).blank? 
            @join_class.new(data).save!
          end
        end
        
        if args[:reload]
          reload
        else
          # we have to do this funky stuff instead of just array difference because +/.uniq returns a regular array,
          # which doesn't have our special methods and configuration anymore
         unless (difference = objs - collection).blank?
           @parent.send("#{@options[:collection_name]}_cache=".to_sym, collection.array_push(*difference))         
         end
        end                 

        @parent.send(@options[:collection_name])       
      end
      
      alias :<< :push      
        
      def delete(objs, args={})

        if objs
          objs = [objs] unless objs.is_a? Array     
        elsif args[:clear]
          objs = collection
          objs = objs.select{|obj| obj.is_a? args[:klass]} if args[:klass]
        else
          raise RuntimeError, "Invalid delete parameters (has_many_polymorphs)."
        end

        records = []
          objs.each do |obj|
            records += join_records.select do |record| 
               record.send(@options[:type_key]) == obj.class.base_class.to_s and 
               record.send(@options[:id_key]) == obj.id
            end
          end

        reload if args[:reload]
        unless records.blank?
          records.map(&:destroy)
          # XXX could be faster if we reversed the loops
          deleted_items = collection.select do |item|
            records.select {|join_record|
              join_record.send(@options[:type_key]) == item.class.base_class.name and
              join_record.send(@options[:id_key]) == item.id
            }.length > 0
          end          
          # keep the cache fresh, while we're at it. see comment in .push          
          deleted_items.each { |item| collection.array_delete(item) }
          @parent.send("#{@options[:collection_name]}_cache=", collection)
          
          return deleted_items unless deleted_items.empty?
        end
        nil
      end  
      
      def clear(klass = nil)
        result = delete(nil, :clear => true, :klass => klass) 
        return result if result
        collection
      end                      
      
      def reload
        # reset the cache, postponing reloading from the db until we really need it
        @parent.reload
      end
        
    private       
      def join_records
        @parent.send(ActiveRecord::Associations::ClassMethods.demodulate(@options[:through]))
      end
      
      def collection
        @parent.send(@options[:collection_name])      
      end
      
    end
  end


  class Base
    # turns an array of hashes (db rows) into a hash consisting of :all (array of everything) and
    # a hash key for each class type it finds, e.g. :posts and :comments 
    private
    def objectify_polymorphic_array(array, join_model, type_field)
      join_model = join_model.constantize
      arrays_hash = {}

      array.each do |element|
        klass = element["#{join_model.table_name}_#{type_field}"].constantize
        association = ActiveRecord::Associations::ClassMethods.demodulate(klass.name.pluralize.underscore.downcase)
        hash = {}

#        puts "Class #{klass.inspect}"
#        puts "Association name: #{association.inspect}"

        element.each do |key, value| 
#          puts "key #{key} - value #{value.inspect}"
          if key =~ /^#{association}_(.+)/ 
            hash[$1] = value
#            puts "#{$1.inspect} assigned #{value.inspect}"
          end
        end

        object = klass.instantiate(hash)

        arrays_hash[:all] ||= []
        arrays_hash[association] ||= []
        arrays_hash[:all] << object
        arrays_hash[association] << object
      end

      arrays_hash
    end
  end
end

#require 'ruby-debug'
#Debugger.start

