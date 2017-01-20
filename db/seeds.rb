# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create([{ username: 'Jimmy', privilege:'admin', password: 'badpass'}])

Request.create([{ req_id: 35164, datetime: Time.new(2017) , user: 'austin', item: 'transistor' , quantity: 5, reason: 'got bored', status: 'outstanding', request_type: 'damaged', instances: {instancearray: ["0x35b2", "0x44a5", "0xa241"]}}])

Item.create([{ unique_name: 'oscilloscope', quantity: 8, model_number: '???', description: 'measure stuff' , tags: {tagarray: ["0x35b2", "0x44a5", "0xa241"]}, instances: {instancearray: ["0x000", "0x001", "0xf163"]}}])

Tag.create([{ name: 'expensive'}])

Tag.create([{ name: 'rich'}])

Tag.create([{ name: 'broke'}])

Tag.create([{ name: '110'}])
