FactoryBot.define do
  factory :note do
    fab_id { 1 }
    body { "MyText" }
    forward { false }
    achivement { false }
  end
end
