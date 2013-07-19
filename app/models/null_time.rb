class NullTime
  include Comparable

  def <=>(another)
    -1 # any other Time object is always greater
  end
end
