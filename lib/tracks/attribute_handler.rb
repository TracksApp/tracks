module Tracks

  class AttributeHandler
    attr_reader :attributes

    def initialize(user, attributes)
      @user = user
      @orig_attributes = attributes
      @attributes = normalize(attributes)
    end

    def get(attribute)
      @attributes[attribute.to_sym] 
    end

    def set(key, value)
      @attributes[key.to_sym] = value
    end

    def set_if_nil(key, value)
      @attributes[key.to_sym] ||= value
    end

    def except(key)
      AttributeHandler.new(@user, @attributes.except(key.to_sym))
    end

    def key?(key)
      @attributes.key?(key.to_sym)
    end

    def selector_key_present?(key)      
      @attributes.key?(key.to_sym)
    end

    def parse_date(date)
      set(date, @user.prefs.parse_date(get(date)))
    end

    def parse_collection(object_type, relation, name)
      object = nil
      new_object_created = false

      if specified_by_name?(object_type)
        # find or create context or project by given name
        object, new_object_created = find_or_create_by_name(relation, name)
      else
        # find context or project by its id
        object = attribute_with_id_of(object_type).present? ? relation.find(attribute_with_id_of(object_type)) : nil
      end
      @attributes[object_type] = object
      return object, new_object_created
    end

    def attribute_with_id_of(object_type)
      map = { project: 'project_id', context: 'context_id' }
      get map[object_type]
    end

    def find_or_create_by_name(relation, name)
      new_object_created = false

      object = relation.where(:name => name).first
      unless object
        object = relation.build(:name => name)
        new_object_created = true
      end
      
      return object, new_object_created
    end      

    def specified_by_name?(object_type)
      self.send("#{object_type}_specified_by_name?")
    end

    def project_specified_by_name?
      return false if get(:project_id).present?
      return false if project_name.blank?
      return false if project_name == 'None'
      true
    end

    def context_specified_by_name?
      return false if get(:context_id).present?
      return false if context_name.blank?
      true
    end

    def project_name
      get(:project_name).try(:strip)
    end

    def context_name
      get(:context_name).try(:strip)
    end

    def normalize(attributes)
      # make sure the hash keys are all symbols
      Hash[attributes.map{|k,v| [k.to_sym,v]}]
    end

  end

end