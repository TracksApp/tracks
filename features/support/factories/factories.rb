FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "testuser#{n}" }
    password "secret"
    password_confirmation { |user| user.password }
    is_admin false
  end

  factory :context do
    sequence(:name) { |n| "testcontext#{n}" }
    hide false
    created_at Time.now.utc
  end

  factory :project do
    sequence(:name) { |n| "testproject#{n}" }
  end

  factory :todo do
    sequence(:description) { |n| "testtodo#{n}" }
    association :context
  end
end