FactoryGirl.define do
  factory :where_message do
    association :user
    body %w(wfh auw eom flex wfl pto vacation am pm sick sl).sample(3).join(' ')
    sent_at 5.minutes.ago
  end
end
