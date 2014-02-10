require_relative '../test_helper'

class AttributeHandlerTest < ActiveSupport::TestCase
  fixtures :users

  def test_setting_attributes
    h = Tracks::AttributeHandler.new(nil, {})

    h.set('test', '123')
    h['other']='one'
    assert_equal '123', h.attributes[:test], ":test should be added"
    assert_nil h.attributes['test'],         "string should be converted to symbol"
    assert_equal 'one', h[:other],           ":other should be added as symbol using []="

    assert_nil h.attributes[:new]
    h.set_if_nil(:new, 'value')
    assert_equal 'value', h.attributes[:new], "value should be set for new key"
    h.set_if_nil(:new, 'other')
    assert_equal 'value', h.attributes[:new], "value should not be set for existing key"

    h.attributes[:empty] = nil 
    h.set_if_nil(:empty, "test")
    assert_equal "test", h.attributes[:empty], "nil value should be overwritten"
  end

  def test_getting_attributes
    h = Tracks::AttributeHandler.new(nil, { :get => "me"} )
    assert h.key?(:get),  "attributehandler should have key :get"
    assert h.key?('get'), "attributehandler should have key :get"
    assert_equal "me", h.attributes[:get], "attributehandler should have key :get"
    assert_equal "me", h.get('get'), "key should be converted to symbol"
    assert_equal "me", h[:get], "AttributeHandler should act like hash"
  end

  def test_removing_attributes
    h = Tracks::AttributeHandler.new(nil, { :i_am => "here"} )
    assert h.key?(:i_am)

    h.except(:i_am)
    assert h.key?(:i_am), "AttributeHandler should be immutable"

    h2 = h.except("i_am")
    assert !h2.key?(:i_am), "key as symbol should be removed"
  end

  def test_project_specified_by_name
    h = Tracks::AttributeHandler.new(nil, { } )

    assert !h.project_specified_by_name?, "project is not specified by id or by name"

    h[:project_id]=4
    assert !h.project_specified_by_name?, "project is specified by id, not by name"

    h = h.except(:project_id)
    h[:project_name] = "A project"
    assert h.project_specified_by_name?, "project is specified by name"

    h[:project_name] = "None"
    assert !h.project_specified_by_name?, "None is special token to specify nil-project"
  end

  def test_context_specified_by_name
    h = Tracks::AttributeHandler.new(nil, { } )
    assert !h.context_specified_by_name?, "context is not specified by id or by name"

    h["context_id"] = 4
    assert !h.context_specified_by_name?, "context is specified by id, not by name"

    h = h.except(:context_id)
    h[:context_name] = "A context"
    assert h.context_specified_by_name?, "context is specified by name"
  end

  def test_parse_collection
    admin   = users(:admin_user)
    project = admin.projects.first
    h = Tracks::AttributeHandler.new(admin, { "project_id" => project.id } )

    parsed_project, new_project_created = h.parse_collection(:project, admin.projects)
    assert !new_project_created, "should find existing project"
    assert_equal project.id, parsed_project.id, "it should find the project"

    h = Tracks::AttributeHandler.new(admin, { "project_name" => project.name } )

    parsed_project, new_project_created = h.parse_collection(:project, admin.projects)
    assert !new_project_created, "should find existing project"
    assert_equal project.id, parsed_project.id, "it should find the project"

    h = Tracks::AttributeHandler.new(admin, { "project_name" => "new project" } )

    parsed_project, new_project_created = h.parse_collection(:project, admin.projects)
    assert new_project_created, "should detect that no project exist with that name"
    assert_equal "new project", parsed_project.name, "it should return a new project"
    assert !parsed_project.persisted?, "new project should not be persisted (yet)"
  end

end