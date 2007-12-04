# Extensions needed for Hash#to_query
class Array
  def to_query(key) #:nodoc:
    collect { |value| value.to_query("#{key}[]") } * '&'
  end
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Array #:nodoc:
      module Conversions
        
        def to_xml(options = {})
          raise "Not all elements respond to to_xml" unless all? { |e| e.respond_to? :to_xml }

          options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize : "records"
          options[:children] ||= options[:root].singularize
          options[:indent]   ||= 2
          options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])

          root     = options.delete(:root).to_s
          children = options.delete(:children)

          if !options.has_key?(:dasherize) || options[:dasherize]
            root = root.dasherize
          end

          options[:builder].instruct! unless options.delete(:skip_instruct)

          opts = options.merge({ :root => children })

          xml = options[:builder]
          if empty?
            xml.tag!(root, options[:skip_types] ? {} : {:type => "array"})
          else
            xml.tag!(root, options[:skip_types] ? {} : {:type => "array"}) {
              yield xml if block_given?
              each { |e| e.to_xml(opts.merge!({ :skip_instruct => true })) }
            }
          end
        end

      end
    end
  end
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions

        XML_TYPE_NAMES["Symbol"] = "symbol"
        XML_TYPE_NAMES["BigDecimal"] = "decimal"

        XML_FORMATTING["symbol"] = Proc.new { |symbol| symbol.to_s }
        XML_FORMATTING["yaml"] = Proc.new { |yaml| yaml.to_yaml }

        unless defined?(XML_PARSING)
          XML_PARSING = {
            "symbol"       => Proc.new  { |symbol|  symbol.to_sym },
            "date"         => Proc.new  { |date|    ::Date.parse(date) },
            "datetime"     => Proc.new  { |time|    ::Time.parse(time).utc },
            "integer"      => Proc.new  { |integer| integer.to_i },
            "float"        => Proc.new  { |float|   float.to_f },
            "decimal"      => Proc.new  { |number|  BigDecimal(number) },
            "boolean"      => Proc.new  { |boolean| %w(1 true).include?(boolean.strip) },
            "string"       => Proc.new  { |string|  string.to_s },
            "yaml"         => Proc.new  { |yaml|    YAML::load(yaml) rescue yaml },
            "base64Binary" => Proc.new  { |bin|     Base64.decode64(bin) },
            # FIXME: Get rid of eval and institute a proper decorator here
            "file"         => Proc.new do |file, entity|
              f = StringIO.new(Base64.decode64(file))
              eval "def f.original_filename() '#{entity["name"]}' || 'untitled' end"
              eval "def f.content_type()      '#{entity["content_type"]}' || 'application/octet-stream' end"
              f
            end
          }

          XML_PARSING.update(
            "double"   => XML_PARSING["float"],
            "dateTime" => XML_PARSING["datetime"]
          )
        end

        module ClassMethods
          def from_xml(xml)
            # TODO: Refactor this into something much cleaner that doesn't rely on XmlSimple
            typecast_xml_value(undasherize_keys(XmlSimple.xml_in_string(xml,
              'forcearray'   => false,
              'forcecontent' => true,
              'keeproot'     => true,
              'contentkey'   => '__content__')
            ))
          end
          
          private
            def typecast_xml_value(value)
              case value.class.to_s
                when "Hash"
                  if value.has_key?("__content__")
                    content = translate_xml_entities(value["__content__"])
                    if parser = XML_PARSING[value["type"]]
                      if parser.arity == 2
                        XML_PARSING[value["type"]].call(content, value)
                      else
                        XML_PARSING[value["type"]].call(content)
                      end
                    else
                      content
                    end
                  elsif value['type'] == 'array'
                    child_key, entries = value.detect { |k,v| k != 'type' }   # child_key is throwaway
                    if entries.nil?
                      []
                    else
                      case entries.class.to_s   # something weird with classes not matching here.  maybe singleton methods breaking is_a?
                      when "Array"
                        entries.collect { |v| typecast_xml_value(v) }
                      when "Hash"
                        [typecast_xml_value(entries)]
                      else
                        raise "can't typecast #{entries.inspect}"
                      end
                    end
                  elsif value['type'] == 'string' && value['nil'] != 'true'
                    ""
                  else
                    xml_value = (value.blank? || value['type'] || value['nil'] == 'true') ? nil : value.inject({}) do |h,(k,v)|
                      h[k] = typecast_xml_value(v)
                      h
                    end
                   
                    # Turn { :files => { :file => #<StringIO> } into { :files => #<StringIO> } so it is compatible with
                    # how multipart uploaded files from HTML appear
                    if xml_value.is_a?(Hash) && xml_value["file"].is_a?(StringIO)
                      xml_value["file"]
                    else
                      xml_value
                    end
                  end
                when "Array"
                  value.map! { |i| typecast_xml_value(i) }
                  case value.length
                    when 0 then nil
                    when 1 then value.first
                    else value
                  end
                when "String"
                  value
                else
                  raise "can't typecast #{value.inspect}"
              end
            end
        end
      end
    end
  end
end