module UrlFriendlyName

  def self.included(base)
    base.extend ClassMethods
  end

  def url_friendly_name
    name.gsub(/_/,'__').gsub(/ /,'_').gsub(/\./,'__dot__')
  end
  
  module ClassMethods
  
    def find_by_url_friendly_name(url_friendly_name)
      name = url_friendly_name.gsub(/__dot__/,'.').gsub(/([^_])_(?!_)/,'\1 ').gsub(/__/,'_') #second regex replaces all single underscores with spaces
      self.find_by_name(name)
    end

  end

end