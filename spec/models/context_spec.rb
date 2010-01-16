require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
 
describe Context do
  def valid_attributes
    {:name => 'Errands'}
  end
 
  before(:each) do
    @context = Context.new
  end

  it 'has many users' do
    Context.should have_many(:todos).
      with_order('todos.completed_at DESC').
      with_dependent(:delete_all).
      with_include(:project)
  end

  it_should_belong_to :user

  it_should_validate_presence_of :name, 'context must have a name'
  it_should_validate_length_of :name, :maximum => 255,
    :message_too_long => 'context name must be less than 256 characters'
  it_should_validate_uniqueness_of :name, 'already exists' # TODO: scope user_id
  it_should_not_accept_as_valid :name, ',',
    :message => "cannot contain the comma (',') character"

  it 'is hidden when hide is true' do
    Context.new(:hide => false).should_not be_hidden
    Context.new(:hide => true).should be_hidden
  end

  it 'produces correct summary depending on visibility' do
    Context.new(:hide => true).summary(3).should == '<p>3. Context is Hidden.</p>'
    Context.new(:hide => false).summary(3).should == '<p>3. Context is Active.</p>'
  end

  it 'returns name as title' do
    Context.new(:name => 'foo').title.should == 'foo'
  end

  it 'returns an instance NullContext for null_object' do
    Context.null_object.should be_an_instance_of(NullContext)
  end

  it "returns feed options with description containing user's name" do
    user = mock_model(User, :display_name => 'simon')
    feed_options_for_user = Context.feed_options(user)
    feed_options_for_user[:title].should == 'Tracks Contexts'
    feed_options_for_user[:description].should == 'Lists all the contexts for simon'
  end

  describe 'when finding by namepart' do
    fixtures :todos, :contexts

    it 'finds with exact match' do
      Context.find_by_namepart('agenda').should == contexts(:agenda)
    end

    it 'finds with partial match' do
      Context.find_by_namepart('age').should == contexts(:agenda)
    end

    it 'deletes todos within context when context deleted' do
      contexts(:agenda).should have(3).todos
      call_todos = contexts(:agenda).todos
      contexts(:agenda).destroy
      Todo.find(:all).should_not include(call_todos)
    end
  end

  describe 'when counting todos' do
    fixtures :todos, :contexts, :users, :preferences

    it 'returns correct number of completed todos' do
      contexts(:call).done_todos.should_not have(:any).items
      contexts(:call).todos.first.complete!
      Context.find(contexts(:call).id).done_todos.should have(1).items
    end

    it 'returns correct number of not done todos' do
      contexts(:agenda).todos.not_completed.should have(2).items
      contexts(:agenda).todos.last.complete!
      contexts(:agenda).todos.not_completed.should have(1).items
    end
  end
end

describe NullContext do
  before(:each) do
    @context = NullContext.new
  end

  it 'is nil' do
    @context.should be_nil
  end

  it 'has no id' do
    @context.id.should be_nil
  end

  it 'has a blank name' do
    @context.name.should be_blank
  end
end
