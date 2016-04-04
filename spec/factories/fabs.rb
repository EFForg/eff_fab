FactoryGirl.define do
  factory :fab do
    user_id 1
  end

  factory :fab_due_in_prior_period, parent: :fab do
    after(:create) do |fab|
      fab.period = (Fab.get_start_of_current_fab_period - 7.days)
      fab.backward.first.update_attributes(body: "I have an old note")
    end
  end

  factory :fab_due_in_current_period, parent: :fab do
    after(:create) do |fab|
      fab.period = (Fab.get_start_of_current_fab_period)
      fab.backward.first.update_attributes(body: "I have a note")
    end
  end

end
