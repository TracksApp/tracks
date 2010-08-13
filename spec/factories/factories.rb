Factory.define :user do |u|
  u.sequence(:login) { |n| "testuser#{n}" }
  u.password "secret"
  u.password_confirmation { |user| user.password }
  u.is_admin false
end

Factory.define :context do |c|
  c.sequence(:name) { |n| "testcontext#{n}" }
  c.hide false
  c.created_at Time.now.utc
end