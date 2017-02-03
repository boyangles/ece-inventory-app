FactoryGirl.define do

  factory :admin, class: User do
    username "admin"
    password "password"
    email "admin@duke.edu"
    privilege 2
    status 1
    email_confirmed true
  end

  factory :approved_user, class: User do
    username "approved_user"
    password "password"
    email "approved_user@duke.edu"
    status 1
    privilege 0
    email_confirmed true
  end

  factory :unnapproved_user, class: User do
    username "unnapproved_user"
    password "password"
    email "UnnaprovedUser@duke.edu"
    status 0
    privilege 0
    email_confirmed true
  end

  factory :email_not_confirmed_user, class: User do
    username "email_not_approved"
    password "password"
    email "email_not_approved@duke.edu"
    status 0
    email_confirmed false
  end
end