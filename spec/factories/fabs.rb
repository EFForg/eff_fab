FactoryGirl.define do
  factory :fab do
    user_id 1
  end

  factory :fab_from_last_week, parent: :fab do
    period (DateTime.now - 7.days)
  end


end
