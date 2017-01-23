class CreateUserSignupRequest < ActiveRecord::Migration[5.0]
  def change
    create_table :user_signup_requests do |t|
      t.string :email
      t.string :username
    end
  end
end
