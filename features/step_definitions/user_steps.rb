Given /^the following user records?$/ do |table|
  User.delete_all
  table.hashes.each do |hash|
    user = FactoryGirl.create(:user, hash)
    user.create_preference({:locale => 'en'})
  end
end

Given /^the following user records with hash algorithm$/ do |table|
  User.delete_all
  table.hashes.each do | hash |
    password = hash[:password]
    algorithm = hash[:algorithm]
    hash.delete("algorithm")

    user = FactoryGirl.create(:user, hash)

    case algorithm
    when 'bcrypt'
      user.change_password( password, password )
      user.reload
      expect(BCrypt::Password.new(user.crypted_password)).to eq(password)
    when 'sha1'
      user.password = user.password_confirmation = nil
      user.send(:write_attribute, :crypted_password, user.sha1(password))
      user.save
      user.reload
      expect(user.crypted_password).to eq(user.sha1(password))
    else
      raise "Unknown hashing algorithm: #{algorithm}"
    end

    user.create_preference({:locale => 'en'})
  end
end

Given("no users exists") do
  User.delete_all
end

When(/^I change my password to "([^"]*)"$/) do |password|
  step 'I should be on the change password page'
  fill_in "user[password]", :with => password
  fill_in "user[password_confirmation]", :with => password
  click_button "Change password"
end

When /^I delete the user "([^\"]*)"$/ do |username|
  # click "//tr[@id='user-3']//img"
  # assert_confirmation "Warning: this will delete user 'john', all their actions, contexts, project and notes. Are you sure that you want to continue?"
  user = User.where(:login => username).first
  expect(user).to_not be_nil

  handle_js_confirm do
    page.find(:xpath, "//tr[@id='user-#{user.id}']//img").click
  end
  expect(get_confirm_text).to eq("Warning: this will delete user '#{user.login}', all their actions, contexts, project and notes. Are you sure that you want to continue?")
  
  expect(page).to_not have_css("tr#user-#{user.id}")
end

Then /^I should see that a user named "([^\"]*)" is not present$/ do |username|
  step "I should not see \"#{username} (\""
end

Then "I should be an admin" do
  # just check on the presence of the menu item for managing users
  step "I should see \"Manage users\""
end
