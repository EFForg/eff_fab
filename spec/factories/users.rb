FactoryGirl.define do
  factory :user do
    name "Test User"
    sequence(:email) {|n| "person_#{n}@example.com" }
    password "please123"
  end

end
