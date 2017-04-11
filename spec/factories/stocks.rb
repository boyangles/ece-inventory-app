FactoryGirl.define do
  factory :stock do

    item do
      create :item
    end

    serial_tag { Faker::Number.number(8)}
    available true
    
  end
end
