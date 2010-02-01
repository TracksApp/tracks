# XSD4R - XML Schema Namespace library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/datatypes'


module XSD


class NS
  Namespace = 'http://www.w3.org/XML/1998/namespace'

  KNOWN_TAG = {
    XSD::Namespace => 'xsd',
    XSD::InstanceNamespace => 'xsi',
  }

  class Assigner
    attr_reader :known_tag

    def initialize(known_tag)
      @known_tag = known_tag.dup
      @count = 0
    end

    def assign(ns)
      if @known_tag.key?(ns)
        return @known_tag[ns]
      end
      @count += 1
      "n#{@count}"
    end
  end

  attr_reader :default_namespace

  class FormatError < Error; end

public

  def initialize(tag2ns = nil)
    @tag2ns = tag2ns || ns_default
    @ns2tag = @tag2ns.invert
    @assigner = nil
    @default_namespace = nil
  end

  def known_tag
    @assigner ||= Assigner.new(default_known_tag)
    @assigner.known_tag
  end

  def assign(ns, tag = nil)
    if tag == ''
      if ns.empty?
        @default_namespace = nil
      else
        @default_namespace = ns
      end
      tag
    else
      @assigner ||= Assigner.new(default_known_tag)
      tag ||= @assigner.assign(ns)
      @ns2tag[ns] = tag
      @tag2ns[tag] = ns
      tag
    end
  end

  def assigned?(ns)
    @default_namespace == ns or @ns2tag.key?(ns)
  end

  def assigned_as_tagged?(ns)
    @ns2tag.key?(ns)
  end

  def assigned_tag?(tag)
    @tag2ns.key?(tag)
  end

  def clone_ns
    cloned = self.class.new(@tag2ns.dup)
    cloned.assigner = @assigner
    cloned.assign(@default_namespace, '') if @default_namespace
    cloned
  end

  def name(qname)
    if qname.namespace == @default_namespace
      qname.name
    elsif tag = @ns2tag[qname.namespace]
      "#{tag}:#{qname.name}"
    else
      raise FormatError.new("namespace: #{qname.namespace} not defined yet")
    end
  end

  # no default namespace
  def name_attr(qname)
    if tag = @ns2tag[qname.namespace]
      "#{tag}:#{qname.name}"
    else
      raise FormatError.new("namespace: #{qname.namespace} not defined yet")
    end
  end

  def compare(ns, name, rhs)
    if (ns == @default_namespace)
      return true if (name == rhs)
    end
    @tag2ns.each do |assigned_tag, assigned_ns|
      if assigned_ns == ns && "#{assigned_tag}:#{name}" == rhs
	return true
      end
    end
    false
  end

  # $1 and $2 are necessary.
  ParseRegexp = Regexp.new('\A([^:]+)(?::(.+))?\z', nil, 'NONE')

  def parse(str, local = false)
    if ParseRegexp =~ str
      if (name = $2) and (ns = @tag2ns[$1])
        return XSD::QName.new(ns, name)
      end
    end
    XSD::QName.new(local ? nil : @default_namespace, str)
  end

  # For local attribute key parsing
  #   <foo xmlns="urn:a" xmlns:n1="urn:a" bar="1" n1:baz="2" />
  #     =>
  #   {}bar, {urn:a}baz
  def parse_local(elem)
    ParseRegexp =~ elem
    if $2
      ns = @tag2ns[$1]
      name = $2
      if !ns
	raise FormatError.new("unknown namespace qualifier: #{$1}")
      end
    elsif $1
      ns = nil
      name = $1
    else
      raise FormatError.new("illegal element format: #{elem}")
    end
    XSD::QName.new(ns, name)
  end

  def each_ns
    @ns2tag.each do |ns, tag|
      yield(ns, tag)
    end
  end

protected

  def assigner=(assigner)
    @assigner = assigner
  end

private

  def ns_default
    {'xml' => Namespace}
  end

  def default_known_tag
    KNOWN_TAG
  end
end


end
