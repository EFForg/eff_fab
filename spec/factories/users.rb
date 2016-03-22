FactoryGirl.define do
  factory :user do
    name "Test User"
    sequence(:email) {|n| "person_#{n}@example.com" }
    password "please123"
  end

  factory :user_with_completed_fab, parent: :user do
    after(:create) do |user|
      user.upcoming_fab.save
    end
  end

  factory :user_with_incompleted_fab, parent: :user do
  end

end
