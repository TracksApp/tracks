require 'soap/rpc/driver'

server = 'http://localhost:7000/'

app = SOAP::RPC::Driver.new(server, 'urn:styleuse')
app.add_rpc_method('rpc_serv', 'obj1', 'obj2')
app.add_document_method('doc_serv', 'urn:doc_serv#doc_serv',
  [XSD::QName.new('urn:styleuse', 'req')],
  [XSD::QName.new('urn:styleuse', 'res')])
app.add_document_method('doc_serv2', 'urn:doc_serv#doc_serv2',
  [XSD::QName.new('urn:styleuse', 'req')],
  [XSD::QName.new('urn:styleuse', 'res')])
app.wiredump_dev = STDOUT

p app.rpc_serv(true, false)
p app.rpc_serv("foo", "bar")
p app.doc_serv({"a" => "2"})
p app.doc_serv({"a" => {"b" => "2"}})
p app.doc_serv2({"a" => "2"})
p app.doc_serv2({"a" => {"b" => "2"}})
