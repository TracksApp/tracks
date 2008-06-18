steps_for :login do  
  Given "an admin user Reinier with the password abracadabra" do
    @reinier = User.create!(:login => 'reinier', :password => 'abracadabra', :password_confirmation => 'abracadabra', :is_admin => true)
    @reinier.create_preference
  end
  
  Given "Reinier is not logged in" do
  end

  Given "no users exist" do
    User.delete_all
  end
  
  Given "a visitor named Reinier" do
  end
  
  When "Reinier submits the login form with an incorrect password" do
    fills_in 'Login', :with => 'reinier'
    fills_in 'Password', :with => 'incorrectpass'
    clicks_button
  end
  
  When "Reinier visits the login page" do
    visits '/login'
  end
  
  When "Reinier successfully submits the login form" do
    fills_in 'Login', :with => 'reinier'
    fills_in 'Password', :with => 'abracadabra'
    clicks_button
  end
  
  When "Reinier visits the site" do
    visits '/'
  end
  
  When "Reinier successfully submits the signup form" do
    fills_in 'Desired login', :with => 'reinier'
    fills_in 'Choose password', :with => 'abracadabra'
    fills_in 'Confirm password', :with => 'abracadabra'
    clicks_button
  end
  
  Then "he should see a signup form" do
    should_see 'create an admin account'
  end
  
  Then "Reinier should see the tasks listing page" do
    response.should have_tag('title', /list tasks/i)
  end
  
  Then "Reinier should be an admin" do
    response.should have_tag('a', /Admin/i)
  end
  
  Then "Reinier should see the message Login successful" do
    should_see 'Login successful'
  end
  
  Then "Reinier should see the login page again" do
    response.should have_tag('title', /login/i)
  end
  
  Then "Reinier should see the message Login unsuccessful" do
    should_see 'Login unsuccessful'
  end
  
end