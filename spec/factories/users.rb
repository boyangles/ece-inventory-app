FactoryGirl.define do
  factory :user do
    username { FFaker::Name.name }
    email "sample@duke.edu"
    password "password"
    password_confirmation "password"
    status "approved"
    privilege "admin"
  end
end
