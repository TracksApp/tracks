class UsersScenario < Scenario::Base
  def load
    create_preference
    create_user :login => 'johnny', :first_name => 'Johnny',  :last_name => 'Smith'
    create_user :login => 'jane',   :first_name => 'Jane',    :last_name => 'Pilbeam'
    create_user :login => 'sean',   :first_name => 'Sean',    :last_name => 'Pallmer'
  end

  def create_user(attributes={})
    password = attributes[:login] + Time.now.to_s
    attributes = {
      :password   => password,
      :password_confirmation => password,
      :is_admin   => attributes[:is_admin]  || false,
      :preference => preferences(:default)
    }.merge(attributes)
    create_model :user, attributes[:login].downcase.to_sym, attributes
  end

  def create_preference
    create_record :preference, :default, :show_number_completed => 5
  end
end
