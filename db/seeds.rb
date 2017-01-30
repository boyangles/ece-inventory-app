# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Request.create([{ datetime: Time.new(2017) , user: 'austin', item_id: 1 , quantity: 5, reason: 'got bored', status: 'outstanding', request_type: 'damaged', instances: {instancearray: ["0x35b2", "0x44a5", "0xa241"]}}])

Tag.create([{ name: 'expensive'}, { name: 'rich'}, { name: 'broke'}, { name: '1'}])



#Creating Users:

User.create!(
  username: "admin1", 
  email: "example@duke.edu", 
  status: 1,
  privilege: 2, 
  password: "password", 
  password_confirmation: "password", 
  email_confirmed: true
)

100.times do |n|
  username = Faker::Name.name
  email = "example-#{n+1}@duke.edu"
  password = "password"
  User.create!(
    username: username,
    email: email,
    status: 1,
    privilege: 2,
    password: password,
    password_confirmation: password,
    email_confirmed: true
  )    
end

# Creating Items:

15.times do |n|
  quantity = Faker::Number.number(3)
  model_number = Faker::Number.hexadecimal(6)
  description = Faker::Lorem.paragraph(2, true, 1)
  
  Item.create!(
    unique_name: "item-#{n+1}",
    quantity: quantity,
    model_number: model_number,
    description: description,
    tags: {
      tagarray: ["tag1", "tag2", "tag3"]
    },
    instances: {
      instancearray: ["instance1", "instance2", "instance3"]
    }
  )
end

# Creating Requests:
15.times do |n|
  datetime = Faker::Time.between(5.days.ago, Time.now, :all)
  # Obtain random user:
  user = User.offset(rand(User.count)).first
  # Obtain random item:
  item = Item.offset(rand(Item.count)).first
  # Random reason:
  reason = Faker::Lorem.paragraph(2, true, 3)

  Request.create!(
    datetime: datetime,
    user: user.username,
    quantity: item.quantity,
    reason: reason,
    status: "outstanding",
    request_type: "disbursement",
    instances: {
      instancearray: ["instance1", "instance2", "instance3"]
    },
    item_id: item.id
  )
end
  
# Creating Logs:
  # Disbursements:
15.times do |n|
  datetime = Faker::Time.between(30.days.ago, Time.now, :all)
  item = Item.offset(rand(Item.count)).first
  quantity = Faker::Number.number(3)
  user = User.offset(rand(User.count)).first
  request_type = rand(0...3)

  Log.create!(
    datetime: datetime,
    item_id: item.id,
    quantity: quantity,
    user_id: user.id,
    request_type: request_type
  )
end

  # Acquisitions:

  # Destructions:
