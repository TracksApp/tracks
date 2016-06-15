require 'htmlentities'

module HTMLEntityHelper
  def entity(name)
    HTMLEntities.new.decode("&#{name};")
  end

  def nbsp
    entity('nbsp')
  end
end
