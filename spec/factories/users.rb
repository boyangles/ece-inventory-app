FactoryGirl.define do
  factory :user do
    username { FFaker::Name.name }
    email { "#{FFaker::Name.first_name}@duke.edu" }
    password "password"
    password_confirmation "password"
  end
end
