FactoryGirl.define do
  factory :where do
    association :user
    body "wfh auw eom"
    sent_at 5.minutes.ago
  end
end
