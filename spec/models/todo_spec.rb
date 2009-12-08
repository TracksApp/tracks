require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Todo do
  def valid_attributes(attributes={})
    {
      :description => "don't forget the milk",
      :context     => mock_model(Context, :name => 'errands', :destroyed? => false)
    }.merge(attributes)
  end

  def create_todo(attributes={})
    todo = Todo.new(valid_attributes(attributes))
    todo.stub!(:user).and_return(mock_model(User, :date => Time.zone.now))
    todo.save!
    todo
  end

  before(:each) do
    @todo = Todo.new
  end

  it_should_belong_to :context
  it_should_belong_to :project
  it_should_belong_to :user

  it_should_validate_presence_of :description
  it_should_validate_presence_of :context
  it_should_validate_length_of :description,  :maximum => 100
  it_should_validate_length_of :notes,        :maximum => 60_000

  it 'validates presence of show_from when deferred'

  it 'ensures that show_from is a date in the future' do
    todo = Todo.new(valid_attributes)
    todo.stub!(:user).and_return(mock_model(User, :date => Time.zone.now))
    todo.show_from = 3.days.ago
    todo.should have(1).error_on(:show_from)
  end

  it 'allows show_from to be blank' do
    todo = Todo.new(valid_attributes(:show_from => ''))
    todo.should_not have(:any).error_on(:show_from)
  end

  describe 'states' do
    it 'is active on initializing' do
      create_todo.should be_active
    end

    it 'is deferred when show from is in the future' do
      create_todo(:show_from => 1.week.from_now).should be_deferred
    end

    describe 'active' do
      %w(project_hidden completed deferred).each do |from_state|
        it "is activable from `#{from_state}'" do
          todo = create_todo
          todo.state = from_state
          todo.send("#{from_state}?").should be_true
          todo.activate!
          todo.should be_active
        end
      end

      it 'clears show_from when entering active state' do
        todo = create_todo
        todo.show_from = 3.days.from_now
        todo.should be_deferred
        todo.activate!
        todo.should be_active
        todo.show_from.should be_nil
      end

      it 'clears completed_at when entering active state' do
        todo = create_todo
        todo.complete!
        todo.should be_completed
        todo.activate!
        todo.should be_active
        todo.completed_at.should be_nil
      end
    end

    describe 'completed' do
      %w(active project_hidden deferred).each do |from_state|
        it "is completable from `#{from_state}'" do
          todo = create_todo
          todo.state = from_state
          todo.send("#{from_state}?").should be_true
          todo.complete!
          todo.should be_completed
        end
      end

      it 'sets complated_at' do
        todo = create_todo
        todo.complete!
        todo.completed_at.should_not be_nil
      end
    end

    describe 'project_hidden' do
      %w(active deferred).each do |from_state|
        it "is hiddable from `#{from_state}'" do
          todo = create_todo
          todo.state = from_state
          todo.send("#{from_state}?").should be_true
          todo.hide!
          todo.should be_project_hidden
        end
      end

      it 'unhides to deferred when if show_from' do
        todo = create_todo(:show_from => 4.days.from_now)
        todo.hide!
        todo.should be_project_hidden
        todo.unhide!
        todo.should be_deferred
      end

      it 'unhides to active when not show_from' do
        todo = create_todo(:show_from => '')
        todo.hide!
        todo.should be_project_hidden
        todo.unhide!
        todo.should be_active
      end
    end

    describe 'when update_state_from_project is called' do
      it "should unhide when project is active" do
        project = mock_model(Project, :hidden? => false)
        todo = Todo.new(:state => 'project_hidden', :project => project)
        todo.should be_project_hidden
        todo.update_state_from_project
        todo.should be_active
      end
   
      it "should unhide when project is null" do
        todo = Todo.new(:state => 'project_hidden', :project => nil)
        todo.should be_project_hidden
        todo.update_state_from_project
        todo.should be_active
      end
   
      it "should hide when project is hidden" do
        project = mock_model(Project, :hidden? => true)
        todo = Todo.new(:state => 'active', :project => project)
        todo.should be_active
        todo.update_state_from_project
        todo.should be_project_hidden
      end
    end

    it "is deferrable from `active'" do
      todo = create_todo
      todo.activate!
      todo.should be_active
      todo.defer!
      todo.should be_deferred
    end
  end

  describe 'when toggling completion' do
    it 'toggles to active when completed' do
      todo = create_todo
      todo.complete!
      todo.should be_completed
      todo.toggle_completion!
      todo.should be_active
    end

    it 'toggles to completed when not completed' do
      todo = create_todo
      todo.should_not be_completed
      todo.toggle_completion!
      todo.should be_completed
    end
  end

  describe 'when retrieving project' do
    it 'returns project if set' do
      project = mock_model(Project)
      todo = Todo.new(:project => project)
      todo.project.should == project
    end

    it 'returns a NullProject if not set' do
      Todo.new.project.should be_an_instance_of(NullProject)
    end
  end

  describe('when setting show_from') { it 'is speced' }

  it 'is starred if tag is "starred"' do
    todo = create_todo
    todo.should_not be_starred
    todo._add_tags('starred')
    todo.reload
    todo.should be_starred
  end

  describe 'when toggling star flag' do
    it 'toggles to not starred when starred' do
      todo = create_todo
      todo._add_tags('starred')
      todo.should be_starred
      todo.toggle_star!
      todo.reload
      todo.should_not be_starred
    end

    it 'toggles to starred when not starred' do
      todo = create_todo
      todo.should_not be_starred
      todo.toggle_star!
      todo.reload
      todo.should be_starred
    end
  end
end
