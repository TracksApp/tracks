class ActiveRecord::Base

  # the alternative to these taggable?() checks is to explicitly include a
  # TaggingMethods module (which you would create) in each taggable model

  def tag_with list
    # completely replace the existing tag set
    taggable?(true)
    list = tag_cast_to_string(list)
           
    Tag.transaction do # transactions may not be ideal for you here
      current = <%= parent_association_name -%>s.map(&:name)
      _add_tags(list - current)
      _remove_tags(current - list)
    end
    
    self
  end
  
  alias :<%= parent_association_name -%>s= :tag_with
  
  # need to avoid name conflicts with the built-in ActiveRecord association 
  # methods, thus the underscores
  def _add_tags incoming
    taggable?(true)
    tag_cast_to_string(incoming).each do |tag_name|
      begin
        tag = Tag.find_or_create_by_name(tag_name)
        raise Tag::Error, "tag could not be saved: #{tag_name}" if tag.new_record?
        tag.taggables << self
      rescue ActiveRecord::StatementInvalid => e
        raise unless e.to_s =~ /duplicate/i
      end
    end
  end
  
  def _remove_tags outgoing
    taggable?(true)
    outgoing = tag_cast_to_string(outgoing)
<% if options[:self_referential] %>  
    # because of http://dev.rubyonrails.org/ticket/6466
    taggings.destroy(taggings.find(:all, :include => :<%= parent_association_name -%>).select do |tagging| 
      outgoing.include? tagging.<%= parent_association_name -%>.name
    end)
<% else -%>   
    <%= parent_association_name -%>s.delete(<%= parent_association_name -%>s.select do |tag|
      outgoing.include? tag.name    
    end)
<% end -%>
  end

  def tag_list
    taggable?(true)
    <%= parent_association_name -%>s.reload
    <%= parent_association_name -%>s.to_s
  end
  
  private 
  
  def tag_cast_to_string obj
    case obj
      when Array
        obj.map! do |item|
          case item
            when /^\d+$/, Fixnum then Tag.find(item).name # this will be slow if you use ids a lot
            when Tag then item.name
            when String then item
            else
              raise "Invalid type"
          end
        end              
      when String
        obj = obj.split(Tag::DELIMITER).map do |tag_name| 
          tag_name.strip.squeeze(" ")
        end
      else
        raise "Invalid object of class #{obj.class} as tagging method parameter"
    end.flatten.compact.map(&:downcase).uniq
  end 
  
  def taggable?(should_raise = false)    
    unless flag = respond_to?(:<%= parent_association_name -%>s)
      raise "#{self.class} is not a taggable model" if should_raise
    end
    flag
  end

end
