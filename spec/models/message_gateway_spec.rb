require File.dirname(__FILE__) + '/../spec_helper'

describe MessageGateway do
  before :each do
    todo = mock_model(Todo, :description= => nil, :notes= => nil, :context_id= => nil, :save! => nil)
    
    @user = mock_model(User, 
      :prefs => mock_model(Preference, :sms_context => mock_model(Context)),
      :todos => mock('Todo collection', :find => nil, :build => todo),
      :contexts => mock('Context collection', :exists? => true, :find => nil))
    
    User.stub!(:find).and_return(@user)
  end

  def load_message(filename)
    MessageGateway.receive(File.read(File.join(RAILS_ROOT, 'test', 'fixtures', filename)))
  end


  it "should dispatch on From: or To: according to site.yml" do
    SITE_CONFIG['email_dispatch'] = 'from'
    User.should_receive(:find).with(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", '5555555555@tmomail.net'])
    load_message('sample_email.txt')

    SITE_CONFIG['email_dispatch'] = 'to'
    User.should_receive(:find).with(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", 'gtd@tracks.com'])
    load_message('sample_email.txt')
  end
end
