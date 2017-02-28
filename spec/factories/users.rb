FactoryGirl.define do
  factory :user do
    username { FFaker::Name.name }
    email { FFaker::Internet.email.downcase }
    password "password"
    password_confirmation "password"
    status "approved"

    factory :user_admin do
      privilege "admin"
    end

    factory :user_student do
      privilege "student"
    end

    factory :user_manager do
      privilege "manager"
    end

    factory :user_admin_unapproved do
      privilege "admin"
      status "deactivated"
    end
  end
end
