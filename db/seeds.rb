# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Group.create!(name: 'FullAdmin')

Admin.create!(name: 'Atyauristen', email: 'admin@dragonhall.hu', password: 'Helloka123', password_confirmation: 'Helloka123', group: Group.where(:name => 'FullAdmin').first)

Channel.create!(name: 'DragonHall+ SD', domain: 'tv.dragonhall.hu')
Channel.create!(name: 'DragonHall+ HD', domain: 'tv.dragonhall.hu')
