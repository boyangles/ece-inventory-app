# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Tag.create([{ name: 'ECE110'}, { name: 'ECE230'}, { name: 'ECE559'}, { name: 'Resistor'}, { name: 'Transistor'},
           { name: 'Capacitor'}])

#Creating Users:

12.times do |n|
  username = Faker::Name.name
  email = "example-#{n+1}@example.com"
  password = "password"
  User.create!(username: username,
               email: email,
               status: "deactivated",
               privilege: "admin",
               password: password,
               password_confirmation: password)
end


12.times do |n|
  username = Faker::Name.name
  email = "exampleApproved-#{n+1}@example.com"
  password = "password"
 
  usr = User.create!(username: username,
               email: email,
               status: "approved",
               privilege: "admin",
               password: password,
               password_confirmation: password,
               auth_token: Devise.friendly_token)

  # Log.create!(user_id: usr)
end

User.create!(username: "admin", email: "adminusername@example.com", status: "approved",
             privilege: "admin", password: "password", password_confirmation: "password", auth_token: Devise.friendly_token)
User.create!(username: "student", email: "nonadminusername@example.com", status: "approved",
             privilege: "student", password: "password", password_confirmation: "password", auth_token: Devise.friendly_token)
User.create!(username: "manager", email: "manager123@example.com", status: "approved",
             privilege: "manager", password: "password", password_confirmation: "password", auth_token: Devise.friendly_token)

yo = User.create(username:"abcd", email: "f@example.com" , status: "approved",
                 privilege: "student", password: "yoyoyo", password_confirmation: "yoyoyo", auth_token: Devise.friendly_token)

items = %w[Resistor Transistor Oscilloscope RED_LED Green_LED Capacitor Screw Washer BOE-Bot Electrical_Tape Arduino_Kit
            QTI_Sensor Server_Motor Piezo_Speaker Seven_Segment_Display IC_Chip]

items.each do |item|
  quantity = Faker::Number.number(3)
  model_number = Faker::Number.hexadecimal(6)
  description = Faker::Lorem.paragraph(2, true, 1)

  Item.create!(
    unique_name: item,
    quantity: quantity,
    model_number: model_number,
    description: description,
    last_action: "created")
end

## Default Custom Fields
CustomField.create!(field_name: 'location', private_indicator: false, field_type: 'short_text_type')
CustomField.create!(field_name: 'restock_info', private_indicator: true, field_type: 'long_text_type')

# Creating Requests:
50.times do |n|
 # Obtain random user:
 user = User.offset(rand(User.count)).first
 # Random reason:
 reason = Faker::Lorem.paragraph(2, true, 3)

 req = Request.create!(
     user_id: user.id,
     reason: reason,
     status: "outstanding",
     request_type: "disbursement",
 )

 ## Create RequestItems for each
 3.times do
   item = Item.offset(rand(Item.count)).first
   RequestItem.create!(request_id: req.id,
                       item_id: item.id,
                       quantity: rand(1...50))
 end
end


