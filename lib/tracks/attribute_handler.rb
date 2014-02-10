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

    def [](attribute)
      get attribute
    end

    def set(key, value)
      @attributes[key.to_sym] = value
    end

    def set_if_nil(key, value)
      @attributes[key.to_sym] ||= value
    end

    def []=(attribute, value)
      set attribute, value
    end

    def except(key)
      AttributeHandler.new(@user, @attributes.except(key.to_sym))
    end

    def key?(key)
      @attributes.key?(key.to_sym)
    end

    def selector_key_present?(key)      
      key?(key)
    end

    def parse_date(date)
      set(date, @user.prefs.parse_date(get(date)))
    end

    def parse_collection(object_type, relation)
      object = nil
      new_object_created = false

      if specified_by_name?(object_type)
        object, new_object_created = find_or_create_by_name(relation, object_name(object_type))
        # put id of object in @attributes, i.e. set :project_id to project.id
        @attributes[object_type.to_s + "_id"] = object.id unless new_object_created
      else
        # find context or project by its id
        object = attribute_with_id_of(object_type).present? ? relation.find(attribute_with_id_of(object_type)) : nil
      end
      @attributes[object_type] = object
      return object, new_object_created
    end

    def object_name(object_type)
      send("#{object_type}_name")
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

    def safe_attributes
      ActionController::Parameters.new(attributes).permit(
      :context, :project,
      # model attributes
      :context_id, :project_id, :description, :notes, :state, :start_from, 
      :ends_on, :end_date, :number_of_occurences, :occurences_count, :target, 
      :show_from_delta, :recurring_period, :recurrence_selector, :every_other1, 
      :every_other2, :every_other3, :every_day, :only_work_days, :every_count, 
      :weekday, :show_always, :context_name, :project_name, :tag_list,
      # form attributes
      :recurring_period, :daily_selector, :monthly_selector, :yearly_selector, 
      :recurring_target, :daily_every_x_days, :monthly_day_of_week, 
      :monthly_every_x_day, :monthly_every_x_month2, :monthly_every_x_month, 
      :monthly_every_xth_day, :recurring_show_days_before, 
      :recurring_show_always, :weekly_every_x_week, :weekly_return_monday,
      :yearly_day_of_week, :yearly_every_x_day, :yearly_every_xth_day, 
      :yearly_month_of_year2, :yearly_month_of_year,
      # derived attributes
      :weekly_return_monday, :weekly_return_tuesday, :weekly_return_wednesday, 
      :weekly_return_thursday, :weekly_return_friday, :weekly_return_saturday, :weekly_return_sunday
      )    
    end

  end

end