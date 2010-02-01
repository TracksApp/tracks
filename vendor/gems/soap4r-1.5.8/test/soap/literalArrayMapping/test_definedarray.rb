require 'test/unit'
require 'soap/mapping'
require 'soap/processor'
require 'soap/rpc/element'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module SOAP
module Marshal


class TestDefinedArray < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def pathname(filename)
    File.join(DIR, filename)
  end

  def setup
    TestUtil.require(DIR, 'amazonEcDriver.rb')
  end

  def test_amazonresponse
    drv = AWSECommerceServicePortType.new
    drv.wiredump_dev = STDOUT if $DEBUG
    drv.test_loopback_response << File.read(pathname('amazonresponse.xml'))
    obj = drv.itemSearch(ItemSearch.new)
    assert_equal(3, obj.items.item.tracks.disc.size)
  end
end


end
end
