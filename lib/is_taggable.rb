# These methods are adapted from has_many_polymorphs' tagging_extensions

module IsTaggable

  def self.included(klass)
    klass.class_eval do

      # Add tags associations
      has_many :taggings, :as => :taggable
      has_many :tags, :through => :taggings do
        def to_s
          self.to_a.map(&:name).sort.join(Tag::JOIN_DELIMITER)
        end
        def all_except_starred
          self.to_a.reject{|tag| tag.name == Todo::STARRED_TAG_NAME}
        end
      end
      
      def tag_list
        tags.reload
        tags.to_s
      end
            
      def tag_list=(value)
        tag_with(value)
      end
      
      # Replace the existing tags on <tt>self</tt>. Accepts a string of tagnames, an array of tagnames, or an array of Tags.
      def tag_with list
        list = tag_cast_to_string(list)
  
        # Transactions may not be ideal for you here; be aware.
        Tag.transaction do
          current = tags.to_a.map(&:name)
          _add_tags(list - current)
          _remove_tags(current - list)
        end
  
        self
      end

      def has_tag?(tag_name)
        return tags.any? {|tag| tag.name == tag_name}
      end
      
      # Add tags to <tt>self</tt>. Accepts a string of tagnames, an array of tagnames, or an array of Tags.
      #
      # We need to avoid name conflicts with the built-in ActiveRecord association methods, thus the underscores.
      def _add_tags incoming
        tag_cast_to_string(incoming).each do |tag_name|
          # added following check to prevent empty tags from being saved (which will fail)
          if tag_name.present?
            begin
              tag = Tag.where(:name => tag_name).first_or_create
              raise Tag::Error, "tag could not be saved: #{tag_name}" if tag.new_record?
              tags << tag
            rescue ActiveRecord::StatementInvalid => e
              raise unless e.to_s =~ /duplicate/i
            end
          end
        end
      end

      # Removes tags from <tt>self</tt>. Accepts a string of tagnames, an array of tagnames, or an array of Tags.
      def _remove_tags outgoing
        outgoing = tag_cast_to_string(outgoing)
        tags.destroy(*(tags.select{|tag| outgoing.include? tag.name}))
      end
      
      def get_tag_name_from_item(item)
        case item
        # removed next line as it prevents using numbers as tags
        # when /^\d+$/, Fixnum then Tag.find(item).name # This will be slow if you use ids a lot.
        when Tag
          item.name
        when String
          item
        else
          raise "Invalid type"
        end
      end

      def tag_cast_to_string(obj)
        tag_array_from_obj(obj).flatten.compact.map(&:downcase).uniq
      end

      def tag_array_from_obj(obj)
        case obj
        when Array
          obj.map! { |item| get_tag_name_from_item(item) }
        when String
          obj.split(Tag::DELIMITER).map { |tag_name| tag_name.strip.squeeze(" ") }
        else
          raise "Invalid object of class #{obj.class} as tagging method parameter"
        end
      end
            
    end
  end
  
end
