require 'test/unit'
require 'soap/soap'


module SOAP


class TestNestedException < Test::Unit::TestCase
  class MyError < SOAP::Error; end

  def foo
    begin
      bar
    rescue
      raise MyError.new("foo", $!)
    end
  end

  def bar
    begin
      baz
    rescue
      raise MyError.new("bar", $!)
    end
  end

  def baz
    raise MyError.new("baz", $!)
  end

  def test_nestedexception
    begin
      foo
    rescue MyError => e
      trace = e.backtrace.find_all { |line| /test\/unit/ !~ line && /\d\z/ !~ line }
      trace = trace.map { |line| line.sub(/\A[^:]*/, '') }
      assert_equal(TOBE, trace)
    end
  end

  TOBE = [
    ":15:in `foo'",
    ":33:in `test_nestedexception'",
    ":23:in `bar': bar (SOAP::TestNestedException::MyError) [NESTED]",
    ":13:in `foo'",
    ":33:in `test_nestedexception'",
    ":28:in `baz': baz (SOAP::TestNestedException::MyError) [NESTED]",
    ":21:in `bar'",
    ":13:in `foo'",
    ":33:in `test_nestedexception'",
  ]

end


end
