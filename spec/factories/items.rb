FactoryGirl.define do
  factory :item do
    unique_name { FFaker::Product.product }
    quantity { Faker::Number.number(3) }
    description { FFaker::Lorem.paragraph[0..32] }
    model_number { FFaker::Identification.ssn }
    last_action 0
  end
end
