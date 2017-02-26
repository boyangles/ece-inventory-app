FactoryGirl.define do
  factory :request do
    reason { FFaker::Lorem.paragraph[0..32] }
    response { FFaker::Lorem.paragraph[0..32] }
    association :user, factory: :admin, id: 105
  end
end
