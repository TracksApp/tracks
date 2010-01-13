Factory.define :user do |u|
  u.sequence(:login) { |n| "testuser#{n}" }
  u.password "secret"
  u.password_confirmation { |user| user.password }
  u.is_admin false
end