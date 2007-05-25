module ActiveRecord
  module Associations
    
    class PolymorphicError < ActiveRecordError; end
    class PolymorphicMethodNotSupportedError < ActiveRecordError; end
    
    class PolymorphicAssociation < HasManyThroughAssociation

      def <<(*records)
        return if records.empty?

        if @reflection.options[:skip_duplicates]
          _logger_debug "Loading instances for polymorphic duplicate push check; use :skip_duplicates => false and perhaps a database constraint to avoid this possible performance issue"
          load_target
        end
        
        @reflection.klass.transaction do
          flatten_deeper(records).each do |record|
            if @owner.new_record? or not record.respond_to?(:new_record?) or record.new_record?
              raise PolymorphicError, "You can't associate unsaved records."            
            end
            next if @reflection.options[:skip_duplicates] and @target.include? record
            @owner.send(@reflection.through_reflection.name).proxy_target << @reflection.klass.create!(construct_join_attributes(record))
            @target << record if loaded?
          end
        end
        
        self
      end
      
      alias :push :<<
      alias :concat :<<      
     
      def find(*args)
        # super(*(args << returning(Base.send(:extract_options_from_args!, args)) {|opts| opts.delete :include})) # returning is slow
        opts = Base.send(:extract_options_from_args!, args)
        opts.delete :include
        super(*(args + [opts]))
      end      
      
      def construct_scope
        _logger_warn "Warning; not all usage scenarios for polymorphic scopes are supported yet."
        super
      end
     
      def delete(*records)
        records = flatten_deeper(records)
        records.reject! {|record| @target.delete(record) if record.new_record?}
        return if records.empty?
        
        @reflection.klass.transaction do
          records.each do |record|
            joins = @reflection.through_reflection.name
            @owner.send(joins).delete(@owner.send(joins).select do |join|
              join.send(@reflection.options[:polymorphic_key]) == record.id and 
              join.send(@reflection.options[:polymorphic_type_key]) == "#{record.class.base_class}"
            end)
            @target.delete(record)
          end
        end
#        records
      end
      
      def clear(klass = nil)
        load_target
        return if @target.empty?
        
        if klass
          delete(@target.select {|r| r.is_a? klass })
        else
          @owner.send(@reflection.through_reflection.name).clear
          @target.clear
        end
        []
      end

#      undef :sum
#      undef :create!
      
      protected

      def construct_quoted_owner_attributes(*args)
        # no access to returning() here? why not?
        type_key = @reflection.options[:foreign_type_key]
        {@reflection.primary_key_name => @owner.id,
          type_key=> (@owner.class.base_class.name if type_key)}
      end

      def construct_from
        # build the FROM part of the query, in this case, the polymorphic join table
        @reflection.klass.table_name
      end

      def construct_owner
        # the table name for the owner object's class
        @owner.class.table_name
      end
      
      def construct_owner_key
        # the primary key field for the owner object
        @owner.class.primary_key
      end

      def construct_select(custom_select = nil)
        # build the select query
        selected = custom_select || @reflection.options[:select]
      end

      def construct_joins(custom_joins = nil)
        # build the string of default joins
        "JOIN #{construct_owner} AS polymorphic_parent ON #{construct_from}.#{@reflection.options[:foreign_key]} = polymorphic_parent.#{construct_owner_key} " + 
        @reflection.options[:from].map do |plural|
          klass = plural._as_class
          "LEFT JOIN #{klass.table_name} ON #{construct_from}.#{@reflection.options[:polymorphic_key]} = #{klass.table_name}.#{klass.primary_key} AND #{construct_from}.#{@reflection.options[:polymorphic_type_key]} = #{@reflection.klass.quote_value(klass.base_class.name)}"
        end.uniq.join(" ") + " #{custom_joins}"
      end

      def construct_conditions
        # build the fully realized condition string
        conditions = construct_quoted_owner_attributes.map do |field, value|
          "#{construct_from}.#{field} = #{@reflection.klass.quote_value(value)}" if value
        end
        conditions << custom_conditions if custom_conditions
        "(" + conditions.compact.join(') AND (') + ")"
      end

      def custom_conditions
        # custom conditions... not as messy as has_many :through because our joins are a little smarter
        if @reflection.options[:conditions]
          "(" + interpolate_sql(@reflection.klass.send(:sanitize_sql, @reflection.options[:conditions])) + ")"
        end
      end

      alias :construct_owner_attributes :construct_quoted_owner_attributes
      alias :conditions :custom_conditions # XXX possibly not necessary
      alias :sql_conditions :custom_conditions # XXX ditto      

      # construct attributes for join for a particular record
      def construct_join_attributes(record)
        {@reflection.options[:polymorphic_key] => record.id, 
          @reflection.options[:polymorphic_type_key] => "#{record.class.base_class}",          
          @reflection.options[:foreign_key] => @owner.id}.merge(@reflection.options[:foreign_type_key] ? 
        {@reflection.options[:foreign_type_key] => "#{@owner.class.base_class}"} : {}) # for double-sided relationships
      end
                    
      def build(attrs = nil)
        raise PolymorphicMethodNotSupportedError, "You can't associate new records."
      end      

    end
    
  end
end
