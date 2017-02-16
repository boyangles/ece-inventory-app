FactoryGirl.define do
  factory :request do
    quantity { Faker::Number.number(3) }
    reason { FFaker::Lorem.paragraph[0..32] }
    response { FFaker::Lorem.paragraph[0..32] }
    association :user, factory: :user, id: 105
    association :item, factory: :item, id: 106
  end
end
