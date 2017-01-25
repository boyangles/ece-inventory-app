# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Request.create([{ req_id: 35164, datetime: Time.new(2017) , user: 'austin', item: 'transistor' , quantity: 5, reason: 'got bored', status: 'outstanding', request_type: 'damaged', instances: {instancearray: ["0x35b2", "0x44a5", "0xa241"]}}])

Item.create([{ unique_name: 'oscilloscope', quantity: 8, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'resistor', quantity: 50, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'transistor', quantity: 100, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'broken arm', quantity: 30, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'human flesh', quantity: 10, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'a', quantity: 8, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'b', quantity: 50, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'c', quantity: 100, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'd arm', quantity: 30, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'e flesh', quantity: 10, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Item.create([{ unique_name: 'f flesh', quantity: 10, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Tag.create([{ name: 'expensive'}, { name: 'rich'}, { name: 'broke'}, { name: '1'}])

12.times do |n|
  username = Faker::Name.name
  email = "example-#{n+1}@duke.edu"
  password = "password"
  User.create!(username: username,
               email: email,
               status: "waiting",
               privilege: "admin",
               password: password,
               password_confirmation: password)
end


12.times do |n|
  username = Faker::Name.name
  email = "exampleApproved-#{n+1}@duke.edu"
  password = "password"
  User.create!(username: username,
               email: email,
               status: "approved",
               privilege: "admin",
               password: password,
               password_confirmation: password)
end


