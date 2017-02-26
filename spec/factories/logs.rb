FactoryGirl.define do
  factory :log do
    quantity { Faker::Number.number(3) }
    association :user, factory: :admin, id: 200
    association :item, factory: :item, id: 201
  end
end