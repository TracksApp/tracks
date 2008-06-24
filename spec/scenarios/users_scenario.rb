class UsersScenario < Scenario::Base
  def load
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
    }.merge(attributes)
    identifier = attributes[:login].downcase.to_sym
    user = create_model :user, identifier, attributes
    Preference.create(:show_number_completed => 5, :user => user)
  end
end
