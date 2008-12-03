require File.join(File.dirname(__FILE__), '../test_helper.rb')

require "test/unit"

# require "library_file_name"

class FileListTest < Test::Unit::TestCase
  def setup
    
  end
  
  def test__new_files__should_get_mtimes
    filename = "/javascripts/js_1.js"
    filelist = BundleFu::FileList.new([filename])
    
    assert_equal(File.mtime(File.join(RAILS_ROOT, "public", filename)).to_i,filelist.filelist[0][1])
  end
  
  def test__serialization
    filelist_filename = File.join(RAILS_ROOT, "public", "temp")
    filelist = BundleFu::FileList.new("/javascripts/js_1.js")
    
    filelist.save_as(filelist_filename)
    filelist2 = BundleFu::FileList.open(filelist_filename)
    
    assert(filelist == filelist2, "expected to be same, but differed.\n#{filelist.to_yaml}\n\n#{filelist2.to_yaml}")
  ensure
    FileUtils.rm_f(filelist_filename)
  end
  
  def test__equality__same_file_and_mtime__should_equate
    filename = "/javascripts/js_1.js"
    assert BundleFu::FileList.new(filename) == BundleFu::FileList.new(filename)
  end
  
  def test__equality__dif_file_and_mtime__shouldnt_equate
    filename1 = "/javascripts/js_1.js"
    filename2 = "/javascripts/js_2.js"
    assert BundleFu::FileList.new(filename1) != BundleFu::FileList.new(filename2)
  end
  
  def test__clone_item
    b = BundleFu::FileList.new("/javascripts/js_1.js")
    assert b == b.clone
  end
end