module NamePartFinder
  def find_by_namepart(namepart)
    find_by_name(namepart) || find(:first, :conditions => ["name LIKE ?", namepart + '%'])
  end
end