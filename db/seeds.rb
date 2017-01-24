# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Request.create([{ req_id: 35164, datetime: Time.new(2017) , user: 'austin', item: 'transistor' , quantity: 5, reason: 'got bored', status: 'outstanding', request_type: 'damaged', instances: {instancearray: ["0x35b2", "0x44a5", "0xa241"]}}])

Item.create([{ unique_name: 'oscilloscope', quantity: 8, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Tag.create([{ name: 'expensive'}, { name: 'rich'}, { name: 'broke'}, { name: '1'}])

100.times do |n|
  username = Faker::Name.name
  email = "example-#{n+1}@duke.edu"
  password = "password"
  User.create!(username: username,
               email: email,
               status: "approved",
               privilege: "admin",
               password: password,
               password_confirmation: password)
end

User.create!(username: "admin1", email: "example@duke.edu", status: "approved",
             privilege: "admin", password: "password", password_confirmation: "password", email_confirmed: true)
