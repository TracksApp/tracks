Given /^the following user records?$/ do |table|
  User.delete_all
  table.hashes.each do |hash|
    user = Factory(:user, hash)
    user.create_preference({:locale => 'en'})
  end
end

Given /^the following user records with hash algorithm$/ do |table|
  User.delete_all
  table.hashes.each do | hash |
    password = hash[:password]
    algorithm = hash[:algorithm]
    hash.delete("algorithm")

    user = Factory(:user, hash)

    case algorithm
    when 'bcrypt'
      user.change_password( password, password )
      user.reload
      BCrypt::Password.new(user.crypted_password).should == password
    when 'sha1'
      user.password = user.password_confirmation = nil
      user.write_attribute :crypted_password, user.sha1(password)
      user.save
      user.reload
      user.crypted_password.should == user.sha1(password)
    else
      raise "Unknown hashing algorithm: #{algorithm}"
    end

    user.create_preference({:locale => 'en'})
  end
end

When /^I change my password to "([^"]*)"$/ do |password|
  step 'I should be on the change password page'
  %w{password password_confirmation}.each { |name| fill_in "user[#{name}]", :with => password }
  click_button "Change password"
end

Given "no users exists" do
  User.delete_all
end

When /^I delete the user "([^\"]*)"$/ do |username|
  # click "//tr[@id='user-3']//img"
  # assert_confirmation "Warning: this will delete user 'john', all their actions, contexts, project and notes. Are you sure that you want to continue?"
  user = User.find_by_login(username)
  user.should_not be_nil

  handle_js_confirm do
    page.find(:xpath, "//tr[@id='user-#{user.id}']//img").click
  end
  get_confirm_text.should == "Warning: this will delete user '#{user.login}', all their actions, contexts, project and notes. Are you sure that you want to continue?"
  
  wait_until do
    !page.has_css?("tr#user-#{user.id}")
  end
end

Then /^I should see that a user named "([^\"]*)" is not present$/ do |username|
  step "I should not see \"#{username} (\""
end

Then "I should be an admin" do
  # just check on the presence of the menu item for managing users
  step "I should see \"Manage users\""
end
