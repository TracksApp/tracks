class Translate::Storage
  attr_accessor :locale
  
  def initialize(locale)
    self.locale = locale.to_sym
  end
  
  def write_to_file
    Translate::File.new(file_path).write(keys)
  end
  
  def self.file_paths(locale)
    Dir.glob(File.join(root_dir, "config", "locales", "**","#{locale}.yml"))
  end
  
  def self.root_dir
    Rails.root
  end
  
  private
  def keys
    {locale => I18n.backend.send(:translations)[locale]}
  end
  
  def file_path
    File.join(Translate::Storage.root_dir, "config", "locales", "#{locale}.yml")
  end
end
