Given "no users exists" do
  User.delete_all
end

Given "an admin user exists" do
  if @admin_user
    @admin_user.destroy
  end
  @admin_user = User.create!(:login => 'admin', :password => 'abracadabra', :password_confirmation => 'abracadabra')
  @admin_user.is_admin = true # is_admin is protected in user model
  @admin_user.create_preference
  @admin_user.preference.save
  @admin_user.save
end

Given "an admin user Reinier with the password abracadabra" do
  @reinier = User.create!(:login => 'reinier', :password => 'abracadabra', :password_confirmation => 'abracadabra', :is_admin => true)
  @reinier.create_preference
end

Given "an admin user Reinier" do
  Given "an admin user Reinier with the password abracadabra"
end

Given "a logged in user Luis" do
  @luis = User.create!(:login => 'luis', :password => 'sesame', :password_confirmation => 'sesame', :is_admin => false)
  @luis.create_preference
  logged_in_as @luis
end

Given "Reinier is not logged in" do
  #nothing to do
end

Given "a visitor named Reinier" do
  #nothing to do
end
