class Tag < ActiveRecord::Base

  has_many :taggings
  has_many :taggable, :through => :taggings

  DELIMITER = ",".freeze # Controls how to split and join tagnames from strings. You may need to change the <tt>validates_format_of parameters</tt> if you change this.
  JOIN_DELIMITER = ", ".freeze

  # If database speed becomes an issue, you could remove these validations and
  # rescue the ActiveRecord database constraint errors instead.
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  before_create :before_create

  # Callback to strip extra spaces from the tagname before saving it. If you
  # allow tags to be renamed later, you might want to use the
  # <tt>before_save</tt> callback instead.
  def before_create
    self.name = name.downcase.strip.squeeze(' '.freeze)
  end

  def label
    @label ||= name.tr(' '.freeze, '-'.freeze)
  end

  def to_s
    name
  end

end
