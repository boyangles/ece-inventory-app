FactoryGirl.define do

  factory :admin, class: User do
    username "#{Faker::Name.name}"
    password "password"
    email "example@duke.edu"
    privilege 2
    status 1
    email_confirmed true
  end

  factory :approved_user, class: User do
    username "#{Faker::Name.name}"
    password "password"
    email "example@duke.edu"
    status 1
    privilege 0
    email_confirmed true
  end

  factory :unnapproved_user, class: User do
    username "#{Faker::Name.name}"
    password "password"
    email "example@duke.edu"
    status 0
    privilege 0
    email_confirmed true
  end

  factory :email_not_confirmed_user, class: User do
    username "#{Faker::Name.name}"
    password "password"
    email "example@duke.edu"
    status 0
    privilege 0
    email_confirmed false
  end
end