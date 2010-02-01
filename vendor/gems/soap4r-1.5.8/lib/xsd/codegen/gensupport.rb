# XSD4R - Code generation support
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module XSD
module CodeGen

# from the file 'keywords' in 1.9.
KEYWORDS = {}
%w(
__LINE__
__FILE__
BEGIN
END
alias
and
begin
break
case
class
def
defined?
do
else
elsif
end
ensure
false
for
if
in
module
next
nil
not
or
redo
rescue
retry
return
self
super
then
true
undef
unless
until
when
while
yield
).each { |k| KEYWORDS[k] = nil }

# from Module.constants from 1.8 & 1.9
CONSTANTS = {}
%w(
ARGF
ARGV
ArgumentError
Array
BasicObject
Bignum
Binding
Class
Comparable
Continuation
Data
Dir
ENV
EOFError
Enumerable
Errno
Exception
FALSE
FalseClass
File
FileTest
Fixnum
Float
FloatDomainError
GC
Hash
IO
IOError
IndexError
Integer
Interrupt
Kernel
KeyError
LoadError
LocalJumpError
Marshal
MatchData
MatchingData
Math
Method
Module
Mutex
NIL
NameError
NilClass
NoMemoryError
NoMethodError
NotImplementedError
Numeric
Object
ObjectSpace
PLATFORM
Precision
Proc
Process
RELEASE_DATE
RUBY_PATCHLEVEL
RUBY_PLATFORM
RUBY_RELEASE_DATE
RUBY_VERSION
Range
RangeError
Regexp
RegexpError
RuntimeError
STDERR
STDIN
STDOUT
ScriptError
SecurityError
Signal
SignalException
StandardError
String
Struct
Symbol
SyntaxError
SystemCallError
SystemExit
SystemStackError
TOPLEVEL_BINDING
TRUE
Thread
ThreadError
ThreadGroup
Time
TrueClass
TypeError
UnboundMethod
VERSION
VM
ZeroDivisionError
).each { |c| CONSTANTS[c] = nil }


module GenSupport
  def capitalize(target)
    target.sub(/^([a-z])/) { $1.upcase }
  end
  module_function :capitalize

  def uncapitalize(target)
    target.sub(/^([A-Z])/) { $1.downcase }
  end
  module_function :uncapitalize

  def safeconstname(name)
    safename = name.scan(/[a-zA-Z0-9_]+/).collect { |ele|
      GenSupport.capitalize(ele)
    }.join
    if /\A[A-Z]/ !~ safename or keyword?(safename) or constant?(safename)
      "C_#{safename}"
    else
      safename
    end
  end
  module_function :safeconstname

  def safeconstname?(name)
    /\A[A-Z][a-zA-Z0-9_]*\z/ =~ name and !keyword?(name)
  end
  module_function :safeconstname?

  def safemethodname(name)
    postfix = name[/[=?!]$/]
    safename = name.scan(/[a-zA-Z0-9_]+/).join('_')
    safename = uncapitalize(safename)
    safename += postfix if postfix
    if /\A[a-z]/ !~ safename or keyword?(safename)
      "m_#{safename}"
    else
      safename
    end
  end
  module_function :safemethodname

  def safemethodname?(name)
    /\A[a-zA-Z_][a-zA-Z0-9_]*[=!?]?\z/ =~ name and !keyword?(name)
  end
  module_function :safemethodname?

  def safevarname(name)
    safename = uncapitalize(name.scan(/[a-zA-Z0-9_]+/).join('_'))
    if /\A[a-z]/ !~ safename or keyword?(safename)
      "v_#{safename}"
    else
      safename
    end
  end
  module_function :safevarname

  def safevarname?(name)
    /\A[a-z_][a-zA-Z0-9_]*\z/ =~ name and !keyword?(name)
  end
  module_function :safevarname?

  def keyword?(word)
    KEYWORDS.key?(word)
  end
  module_function :keyword?

  def constant?(word)
    CONSTANTS.key?(word)
  end
  module_function :constant?

  def format(str, indent = nil)
    str = trim_eol(str)
    str = trim_indent(str)
    if indent
      str.gsub(/^/, " " * indent)
    else
      str
    end
  end

private

  def trim_eol(str)
    str.collect { |line|
      line.sub(/\r?\n\z/, "") + "\n"
    }.join
  end

  def trim_indent(str)
    indent = nil
    str = str.collect { |line| untab(line) }.join
    str.each do |line|
      head = line.index(/\S/)
      if !head.nil? and (indent.nil? or head < indent)
        indent = head
      end
    end
    return str unless indent
    str.collect { |line|
      line.sub(/^ {0,#{indent}}/, "")
    }.join
  end

  def untab(line, ts = 8)
    while pos = line.index(/\t/)
      line = line.sub(/\t/, " " * (ts - (pos % ts)))
    end
    line
  end

  def dump_emptyline
    "\n"
  end
end


end
end
