require 'soap/rpc/router'
require 'soap/mapping/mapping'
require 'soap/processor'
require 'test/unit'


module SOAP
module Fault


class TestSOAPArray < Test::Unit::TestCase

  # simulate the soap fault creation and parsing on the client
  def test_parse_fault
    router = SOAP::RPC::Router.new('parse_SOAPArray_error')
    soap_fault = pump_stack rescue router.create_fault_response($!)
    env = SOAP::Processor.unmarshal(soap_fault.send_string)
    soap_fault = SOAP::FaultError.new(env.body.fault)
    # in literal service, RuntimeError is raised (not an ArgumentError)
    # any chance to use Ruby's exception encoding in literal service?
    assert_raises(RuntimeError) do
      registry = SOAP::Mapping::LiteralRegistry.new
      SOAP::Mapping.fault2exception(soap_fault, registry)
    end
  end

  def pump_stack(max = 0)
    raise ArgumentError if max > 10
    pump_stack(max+1)
  end
end


end
end
