module SimplyHelpful
  module RecordIdentifier
    extend self

    def polymorphic_url(record, url_writer)
      record.new_record? ? 
        url_writer.send(plural_class_name(record)   + "_url") : 
        url_writer.send(singular_class_name(record) + "_url", record)
    end

    def polymorphic_path(record, url_writer)
      record.new_record? ? 
        url_writer.send(plural_class_name(record)   + "_path") : 
        url_writer.send(singular_class_name(record) + "_path", record)
    end

    def partial_path(record_or_class)
      klass = class_from_record_or_class(record_or_class)
      "#{klass.name.tableize}/#{klass.name.demodulize.underscore}"
    end

    def dom_class(record_or_class, prefix = nil)
      [ prefix, singular_class_name(record_or_class) ].compact * '_'
    end

    def dom_id(record, prefix = nil) 
      prefix ||= 'new' unless record.id 
      [ prefix, singular_class_name(record), record.id ].compact * '_'
    end
  
    def plural_class_name(record_or_class)
      singular_class_name(record_or_class).pluralize
    end
  
    def singular_class_name(record_or_class)
      class_from_record_or_class(record_or_class).name.underscore.tr('/', '_')
    end
    
    private
      def class_from_record_or_class(record_or_class)
        record_or_class.is_a?(Class) ? record_or_class : record_or_class.class
      end
  end
end
