require 'test/unit'
require 'wsdl/xmlSchema/xsd2ruby'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module XSD; module XSD2Ruby


class TestXSD2Ruby < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    Dir.chdir(DIR) do
      gen = WSDL::XMLSchema::XSD2Ruby.new
      gen.location = pathname("section.xsd")
      gen.basedir = DIR
      gen.logger.level = Logger::FATAL
      gen.opt['module_path'] = "XSD::XSD2Ruby"
      gen.opt['classdef'] = nil
      gen.opt['mapping_registry'] = nil
      gen.opt['mapper'] = nil
      gen.opt['force'] = true
      gen.run
      TestUtil.require(DIR, 'mysample.rb', 'mysample_mapping_registry.rb', 'mysample_mapper.rb')
    end
  end

  def teardown
    unless $DEBUG
      File.unlink(pathname("mysample.rb"))
      File.unlink(pathname("mysample_mapping_registry.rb"))
      File.unlink(pathname("mysample_mapper.rb"))
    end
    # leave generated file for debug.
  end

  def test_generate
    compare("expected_mysample.rb", "mysample.rb")
    compare("expected_mysample_mapping_registry.rb", "mysample_mapping_registry.rb")
    compare("expected_mysample_mapper.rb", "mysample_mapper.rb")
  end

  def test_mapper
    mapper = XSD::XSD2Ruby::MysampleMapper.new
    # complexType
    arg = XSD::XSD2Ruby::Section.new(10001, 'name', 'description', 1, Question.new("hello world"))
    obj = mapper.xml2obj(mapper.obj2xml(arg))
    assert_section_equal(arg, obj)
    # element
    arg = XSD::XSD2Ruby::SectionElement.new(10001, 'name', 'description', 1, Question.new("hello world"))
    obj = mapper.xml2obj(mapper.obj2xml(arg))
    assert_section_equal(arg, obj)
    # array
    ele = XSD::XSD2Ruby::Section.new(10001, 'name', 'description', 1, Question.new("hello world"))
    arg = XSD::XSD2Ruby::SectionArray[ele, ele, ele]
    obj = mapper.xml2obj(mapper.obj2xml(arg))
    assert_equal(arg.class, obj.class)
    assert_equal(arg.size, obj.size)
    0.upto(arg.size - 1) do |idx|
      assert_section_equal(arg[idx], obj[idx])
    end
  end

private

  def assert_section_equal(arg, obj)
    assert_equal(arg.class, obj.class)
    assert_equal(arg.sectionID, obj.sectionID)
    assert_equal(arg.name, obj.name)
    assert_equal(arg.description, obj.description)
    assert_equal(arg.index, obj.index)
    assert_equal(arg.firstQuestion.class, obj.firstQuestion.class)
    assert_equal(arg.firstQuestion.something, obj.firstQuestion.something)
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end
