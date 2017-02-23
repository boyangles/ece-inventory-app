FactoryGirl.define do
  factory :user do
    username { FFaker::Name.name }
    email { FFaker::Internet.email }
    password "password"
    password_confirmation "password"
    status "approved"
    privilege "admin"
  end
end
