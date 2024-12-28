# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'factory_bot'
require 'faker'

Dir.glob(Rails.root.join('spec/factories/*.rb')).each { |f| require f }

puts " >> Creating group 'FullAdmin'"
group = Group.find_or_create_by!(name: 'FullAdmin')

unless group.admins.any?
  puts " >> Creating user admin@dragonhall.hu with password 'Helloka123'"
  Admin.create!(name: 'Atyauristen', email: 'admin@dragonhall.hu', password: 'Helloka123',
                password_confirmation: 'Helloka123', group: group)
end

unless Channel.any?
  puts ' >> Creating channels'
  FactoryBot.create(:channel, name: 'DragonHall+ SD', domain: 'tv.dragonhall.hu')
  FactoryBot.create(:channel, name: 'DragonHall+ HD', domain: 'tv.dragonhall.hu')
end

if Video.count < 5
  puts ' >> Stuffing in random fake video objects:'
  99.times do
    v = FactoryBot.create(:video)
    puts "    :: '#{v.title}' is a #{v.video_type} rated #{v.pegi_rating.titleize}"
  end
end
