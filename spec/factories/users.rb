FactoryGirl.define do
  factory :user do
    name "Test User"
    sequence(:email) {|n| "person_#{n}@example.com" }
    password "please123"

    # put user on a team
    before(:create) do |user|
      if user.team_id.nil?
        t = Team.find_or_create_by(name: "Activism")
        user.team_id = t.id
      end
    end
  end

  factory :user_with_yesterweeks_fab, parent: :user_with_completed_fab do
    after(:create) do |user|
      user.fabs << FactoryGirl.create(:fab_due_in_prior_period)
    end
  end

  factory :user_admin, parent: :user do
    role = :admin
  end

  factory :user_with_completed_fab, parent: :user do
    after(:create) do |user|
      # setup fab and note
      fab = user.fabs.find_or_build_this_periods_fab
      n = fab.notes[4]
      n.body = "I have a note"
      n.save
      fab.save
    end
  end

  factory :user_with_incompleted_fab, parent: :user do
  end

end
