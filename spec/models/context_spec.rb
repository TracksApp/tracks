require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ContextSpecHelper
 
   def valid_context_attributes
     {
      :name => "FooBar",
      :position => 1,
      :hide => true,
      :user_id => 1
     }
   end
   
end
 
describe "Context validations" do
  include ContextSpecHelper
 
  before(:each) do
    @context = Context.new
  end
 
  it "should be valid" do
    @context.attributes = valid_context_attributes
    @context.should be_valid
    @context.save
    Context.should have(4).records # 3 in fixtures 1 set up here
  end

  it "should have two errors with a missing name" do
    @context.attributes = valid_context_attributes.except(:name)
    @context.should_not be_valid
    @context.should have(1).error_on(:name)
    @context.error_on(:name).should include('context must have a name')
  end

  it "should have one error with a name of more than 255 characters" do
    @context.name = "z" * 256
    @context.should_not be_valid
    @context.should have(1).error_on(:name)
    @context.errors.on(:name).should eql("context name must be less than 256 characters")
  end

  it "should have one error with name containing comma" do
    @context.name = "Foo,Bar"
    @context.should_not be_valid
    @context.should have(1).error_on(:name)
    @context.errors.on(:name).should eql("cannot contain the comma (',') character")
  end
  
  it "should have one error if name already exists for user" do
    @existing_context = Context.new
    @existing_context.attributes = valid_context_attributes
    @existing_context.save
    @context.attributes = valid_context_attributes
    @context.should_not be_valid
    @context.should have(1).error_on(:name)
    @context.errors.on(:name).should eql("already exists")
  end

  it "should have one record in Context model class" do
    @context.name = "FooBar"
    @context.save
    Context.should have(4).records # 3 in fixture, one set up here
  end
  
end

describe "Context model" do
  fixtures :users, :todos, :contexts, :preferences
  
  include ContextSpecHelper
    
  it "should show hidden" do
    contexts(:call).should be_hide # :hide should be true
  end

  it "should be produce correct .summary text for hidden context" do
    contexts(:call).summary(1).should eql("<p>1. Context is Hidden.</p>")
  end

  it "should show not hidden" do
    contexts(:call).hide = false
    contexts(:call).should_not be_hide # :hide should be true
  end

  it "should produce correct .summary text for active context" do
    contexts(:call).hide = false
    contexts(:call).summary(1).should eql("<p>1. Context is Active.</p>")
  end

  it "should return .title which matches name" do
    contexts(:agenda).title.should eql(contexts(:agenda).name)
  end
  
  it "should .find_by_namepart with exact match" do
    @found = Context.find_by_namepart('agenda')
    @found.should_not eql(nil)
    @found.id.should eql(contexts(:agenda).id)
  end
  
  it "should .find_by_namepart with partial match" do
    @found = Context.find_by_namepart('ag')
    @found.should_not eql(nil)
    @found.id.should eql(contexts(:agenda).id)
  end
  
  it "should return id with .to_param" do
    Context.find(2).to_param.should eql("2")
  end
  
  it "should return feed options" do
    opts = Context.feed_options(users(:admin_user))
    opts[:title].should eql("Tracks Contexts")
    opts[:description].should eql("Lists all the contexts for Admin Schmadmin")
  end
  
  it "should create null Context with .null_object" do
    @empty = Context.null_object
    @empty.should be_an_instance_of(NullContext)
    @empty.id.should eql(nil)
    @empty.name.should eql('')
  end
  
  it "should delete todos within context when context deleted" do
    contexts(:agenda).todos.count.should eql(3)
    agenda_todo_ids = contexts(:agenda).todos.collect{|t| t.id }
    contexts(:agenda).destroy
    agenda_todo_ids.each do |todo_id|
      Todo.find(:all).should_not include(todo_id)
    end
  end
  
  it "should return correct number of done todos" do
    contexts(:agenda).done_todos.size.should eql(1)
    t = contexts(:agenda).not_done_todos[0]
    t.complete!
    t.save!
    Context.find(contexts(:agenda)).done_todos.size.should eql(2)
  end
  
  it "should return correct number of not done todos" do
    contexts(:agenda).not_done_todos.size.should eql(2)
    t = contexts(:agenda).not_done_todos[0]
    t.complete!
    t.save!
    Context.find(contexts(:agenda)).not_done_todos.size.should eql(1)
  end

end
