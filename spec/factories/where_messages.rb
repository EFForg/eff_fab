FactoryGirl.define do
  factory :where_message do
    association :user
    body { Faker::Coffee.notes }
    sent_at 5.minutes.ago
  end
end
