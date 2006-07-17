class Deferred < Todo
  validates_presence_of :show_from
  
  def validate
    if show_from != nil && show_from < Date.today()
      errors.add("Show From", "must be a date in the future.")
    end
  end
end
