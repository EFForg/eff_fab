FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) {|n| "person_#{n}@eff.org" }
    password { "please123" }

    # put user on a team
    before(:create) do |user|
      if user.team_id.nil?
        t = Team.find_or_create_by(name: "Activism")
        user.team_id = t.id
      end
    end

    trait :with_api_key do
      after(:create) { |user| user.create_api_key! }
    end
  end

  factory :user_with_yesterweeks_fab, parent: :user_with_completed_fab do
    after(:create) do |user|
      user.fabs << FactoryBot.create(:fab_due_in_prior_period)
    end
  end

  factory :user_admin, parent: :user do
    role { :admin }
  end

  factory :user_with_completed_fab, parent: :user do
    after(:create) do |user|
      # setup fab and note
      fab = user.fabs.find_or_build_this_periods_fab
      n = fab.notes[4]
      n.body = Faker::Company.catch_phrase
      n.save
      fab.save
    end
  end

  factory :user_with_incompleted_fab, parent: :user

end
