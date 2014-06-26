require 'minimal_test_helper'
require './doc/tracks_cli/tracks_xml_builder'
require 'active_support/time_with_zone'

module TracksCli

  class TracksXmlBuilderTest < Minitest::Test
    def test_all
      todo = {
        description: "test action",
        project_id: 1,
        show_from: Time.utc(2013,1,1,14,00,00),
        notes: "action notes",
        taglist: "one, two",
        context_name: "@home",
        is_dependend: true,
        predecessor: 123
      }

      xml = TracksCli::TracksXmlBuilder.new.build_todo_xml(todo)
      expect = "<todo><description>test action</description>" +
        "<project_id>1</project_id><show-from type=\"datetime\">#{Time.at(todo[:show_from]).xmlschema}</show-from>" +
        "<notes>action notes</notes><tags><tag><name>one</name></tag><tag><name>two</name></tag></tags>" +
        "<context><name>@home</name></context><predecessor_dependencies><predecessor>123</predecessor></predecessor_dependencies></todo>"

      assert_equal expect, xml
    end

    def test_context_name_is_passed_through
      todo = {
        description: "test action",
        project_id: 1,
        context_name: "@home",
      }

      xml = TracksCli::TracksXmlBuilder.new.build_todo_xml(todo)
      expect = "<todo><description>test action</description><project_id>1</project_id><context><name>@home</name></context></todo>"

      assert_equal expect, xml
    end

    def test_context_id_is_used_if_no_context_name_given
      todo = {
        description: "test action",
        project_id: 5,
        context_id: 16,
      }

      xml = TracksCli::TracksXmlBuilder.new.build_todo_xml(todo)
      expect = "<todo><description>test action</description><project_id>5</project_id><context_id>16</context_id></todo>"

      assert_equal expect, xml, "only context_id given, so that should be included"

      todo = {
        description: "test action",
        project_id: 5,
        context_id: 16,
        context_name: "@inbox"
      }

      xml = TracksCli::TracksXmlBuilder.new.build_todo_xml(todo)
      expect = "<todo><description>test action</description><project_id>5</project_id><context><name>@inbox</name></context></todo>"

      assert_equal expect, xml, "both context_id and context_name given, then context_name should be used"
    end

    def test_project_xml_all
      todo = {
        description: "test project",
        default_context_id: 16
      }

      xml = TracksCli::TracksXmlBuilder.new.build_project_xml(todo)
      expect = "<project><name>test project</name><default-context-id>16</default-context-id></project>"

      assert_equal expect, xml
    end

  end

end