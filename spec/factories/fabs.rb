FactoryBot.define do
  factory :fab do
    association :user
  end

  factory :fab_due_in_prior_period, parent: :fab do
    period { Fab.get_start_of_current_fab_period - 7.days }
    created_at { |fab| fab.period }

    after(:create) do |fab|
      fab.backward.first.update_attributes(body: "I have an old note")
    end
  end

  factory :fab_due_in_current_period, parent: :fab do
    period { (Fab.get_start_of_current_fab_period) }
    created_at { |fab| fab.period }

    after(:create) do |fab|
      fab.backward.first.update_attributes(body: "I have a note")
    end
  end

end
