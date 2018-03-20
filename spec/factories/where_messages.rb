FactoryGirl.define do
  factory :where_message do
    association :user
    body "wfh auw eom"
    sent_at 5.minutes.ago
  end
end
