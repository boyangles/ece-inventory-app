FactoryGirl.define do
  factory :tag do
    name { FFaker::Product.product[0..29] }
  end
end