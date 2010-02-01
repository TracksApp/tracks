require 'test/unit'
require 'soap/mapping'
require 'soap/marshal'


module SOAP


class TestMapping < Test::Unit::TestCase

  class MappablePerson
    attr_reader :name
    attr_reader :age

    def initialize(name, age)
      @name, @age = name, age
    end

    def self.soap_marshallable
      true
    end
  end

  class UnmappablePerson
    attr_reader :name
    attr_reader :age

    def initialize(name, age)
      @name, @age = name, age
    end

    def self.soap_marshallable
      false
    end
  end

  def test_mappable
    xml = <<__XML__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <SOAP..TestMapping..MappablePerson env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <name>nahi</name>
      <age>37</age>
    </SOAP..TestMapping..MappablePerson>
  </env:Body>
</env:Envelope>
__XML__
    obj = SOAP::Marshal.load(xml)
    assert_equal(SOAP::TestMapping::MappablePerson, obj.class)
    #
    xml = <<__XML__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <SOAP..TestMapping..UnmappablePerson env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <name>nahi</name>
      <age>37</age>
    </SOAP..TestMapping..UnmappablePerson>
  </env:Body>
</env:Envelope>
__XML__
    obj = SOAP::Marshal.load(xml)
    assert_equal(SOAP::Mapping::Object, obj.class)
  end

  def test_nestedexception
    ele = Thread.new {}
    obj = [ele]
    begin
      SOAP::Marshal.dump(obj)
    rescue ::SOAP::Mapping::MappingError => e
      assert(e.backtrace.find { |line| /\[NESTED\]/ =~ line })
    end
  end

  def test_date
    targets = [
      ["2002-12-31",
	"2002-12-31Z"],
      ["2002-12-31+00:00",
	"2002-12-31Z"],
      ["2002-12-31-00:00",
	"2002-12-31Z"],
      ["-2002-12-31",
	"-2002-12-31Z"],
      ["-2002-12-31+00:00",
	"-2002-12-31Z"],
      ["-2002-12-31-00:00",
	"-2002-12-31Z"],
    ]
    targets.each do |str, expectec|
      d = Date.parse(str)
      assert_equal(d.class, convert(d).class)
      assert_equal(d, convert(d))
    end
  end

  def test_datetime
    targets = [
      ["2002-12-31T23:59:59.00",
	"2002-12-31T23:59:59Z"],
      ["2002-12-31T23:59:59+00:00",
	"2002-12-31T23:59:59Z"],
      ["2002-12-31T23:59:59-00:00",
	"2002-12-31T23:59:59Z"],
      ["-2002-12-31T23:59:59.00",
	"-2002-12-31T23:59:59Z"],
      ["-2002-12-31T23:59:59+00:00",
	"-2002-12-31T23:59:59Z"],
      ["-2002-12-31T23:59:59-00:00",
	"-2002-12-31T23:59:59Z"],
    ]
    targets.each do |str, expectec|
      d = DateTime.parse(str)
      assert_equal(d.class, convert(d).class)
      assert_equal(d, convert(d))
    end
  end

  def convert(obj)
    SOAP::Mapping.soap2obj(SOAP::Mapping.obj2soap(obj))
  end
end


end
