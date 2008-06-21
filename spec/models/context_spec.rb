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
 
 describe Context do
  include ContextSpecHelper
   
   before(:each) do
     @context = Context.new
   end
   
  it "should be valid" do
   @context.name = "FooBar"
   @context.should be_valid
  end
  
  it "should have one error with a name of more than 255 characters" do
    @context.name = "z" * 256
    @context.should have(1).error_on(:name)
  end
  
  it "should have one error with name containing comma" do
    @context.name = "Foo,Bar"
    @context.should have(1).error_on(:name)
  end
  
  it "should have one record in Context model class" do
    @context.name = "FooBar"
    @context.save
    Context.should have(1).record
  end

  it "should be hidden" do
    @context.attributes = valid_context_attributes
    @context.should be_hide # :hide should be true
  end
  
  it "should be produce correct summary text for hidden context" do
    @context.attributes = valid_context_attributes
    @context.summary(1).should eql("<p>1. Context is Hidden.</p>")
  end
  
  it "should be active" do
    @context.attributes = valid_context_attributes
    @context.hide = false
    @context.save
    @context.should_not be_hide # :hide should be true
  end
  
  it "should produce correct summary text for active context" do
    @context.attributes = valid_context_attributes
    @context.hide = false
    @context.save
    @context.summary(1).should eql("<p>1. Context is Active.</p>")
  end
  
 end
