require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", SALT    
    @admin_user = User.find(1)
    @other_user = User.find(2)
  end

  # Test an admin user model
  # 
  def test_admin
    assert_kind_of User, @admin_user
    assert_equal 1, @admin_user.id
    assert_equal "admin", @admin_user.login
    assert_equal "#{Digest::SHA1.hexdigest("#{SALT}--abracadabra--")}", @admin_user.password
    assert_not_nil @admin_user.word
    assert_equal 1, @admin_user.is_admin
  end

  # Test a non-admin user model
  def test_non_admin
    assert_kind_of User, @other_user
    assert_equal 2, @other_user.id
    assert_equal "jane", @other_user.login
    assert_equal "#{Digest::SHA1.hexdigest("#{SALT}--sesame--")}", @other_user.password
    assert_not_nil @other_user.word
    assert_equal 0, @other_user.is_admin
  end

  # ============================================
  # Validations
  # ============================================
  
  # Test a password shorter than 5 characters
  # 
  def test_validate_short_password
    assert_equal "#{Digest::SHA1.hexdigest("#{SALT}--sesame--")}", @other_user.password
    @other_user.password = "four"
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too short (minimum is 5 characters)", @other_user.errors.on(:password)
  end

  # Test a password longer than 40 characters
  # 
  def test_validate_long_password
    assert_equal "#{Digest::SHA1.hexdigest("#{SALT}--sesame--")}", @other_user.password
    @other_user.password = generate_random_string(41)
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too long (maximum is 40 characters)", @other_user.errors.on(:password)
  end  
  
  # Test that correct length password is valid
  # 
  def test_validate_correct_length_password
    assert_equal "#{Digest::SHA1.hexdigest("#{SALT}--sesame--")}", @other_user.password
    @other_user.password = generate_random_string(6)
    assert @other_user.save
  end
  
  # Test a missing password
  # 
  def test_validate_missing_password
    assert_equal 2, @other_user.id
    @other_user.password = ""
    assert !@other_user.save
    assert_equal 2, @other_user.errors.count
    assert_equal ["is too short (minimum is 5 characters)", "can't be blank"], @other_user.errors.on(:password)
  end
  
  # Test a login shorter than 3 characters
  # 
  def test_validate_short_login
    assert_equal "jane", @other_user.login
    @other_user.login = "ba"
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too short (minimum is 3 characters)", @other_user.errors.on(:login)
  end
  
  # Test a login longer than 80 characters
  # 
  def test_validate_long_login
    assert_equal "jane", @other_user.login
    @other_user.login = generate_random_string(81)
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too long (maximum is 80 characters)", @other_user.errors.on(:login)
  end  
  
  # Test that correct length login is valid
  # 
  def test_validate_correct_length_login
    assert_equal "jane", @other_user.login
    @other_user.login = generate_random_string(6)
    assert @other_user.save
  end
  
  # Test a missing login
  # 
  def test_validate_missing_login
    assert_equal 2, @other_user.id
    @other_user.login = ""
    assert !@other_user.save
    assert_equal 2, @other_user.errors.count
    assert_equal ["is too short (minimum is 3 characters)", "can't be blank"], @other_user.errors.on(:login)
  end

end
