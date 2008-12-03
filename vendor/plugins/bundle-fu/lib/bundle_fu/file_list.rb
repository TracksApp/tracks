require 'fileutils.rb'

class BundleFu::FileList
  attr_accessor :filelist
  
  def initialize(filenames=[])
    self.filelist = []
    
    self.add_files(filenames)
  end
  
  def initialize_copy(from)
    self.filelist = from.filelist.collect{|entry| entry.clone}
  end
  
  def filenames
    self.filelist.collect{ |entry| entry[0] }
  end
  
  def update_mtimes
    old_filenames = self.filenames
    self.filelist = []
    # readding the files will effectively update the mtimes
    self.add_files(old_filenames)
    self
  end
  
  def self.open(filename)
    return nil unless File.exists?(filename)
    b = new
    File.open(filename, "rb") {|f|
      b.filelist = Marshal.load(f)  # rescue [])
    }
    b
  rescue
    nil
  end
  
  # compares to see if one file list is exactly the same as another
  def ==(compare)
    return false if compare.nil?
    throw "cant compare with #{compare.class}" unless self.class===compare
    
    self.filelist == compare.filelist
  end
  
  def add_files(filenames=[])
    filenames.each{|filename|
      self.filelist << [ extract_filename_from_url(filename), (File.mtime(abs_location(filename)).to_i rescue 0) ]
    }
  end
  
  def extract_filename_from_url(url)
    url.gsub(/^https?:\/\/[^\/]+/i, '')
  end
  
  def save_as(filename)
    File.open(filename, "wb") {|f| f.puts Marshal.dump(self.filelist)}
  end
protected
  def abs_location(filename)
    File.join(RAILS_ROOT, "public", filename)
  end
end
