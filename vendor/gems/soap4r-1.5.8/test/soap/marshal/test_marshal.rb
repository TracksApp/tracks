require 'test/unit'
require 'soap/marshal'
require File.join(File.dirname(File.expand_path(__FILE__)), 'marshaltestlib')


if RUBY_VERSION > "1.7.0"


module SOAP
module Marshal
class TestMarshal < Test::Unit::TestCase
  include MarshalTestLib

  def encode(o)
    SOAPMarshal.dump(o)
  end

  def decode(s)
    SOAPMarshal.load(s)
  end
end
end
end


end
