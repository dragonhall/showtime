FactoryBot.define do
  factory :admin do
    name { 'Super Admin' }
    email { 'admin@example.com' } 
    password { 'Secret123!' }
    password_confirmation { 'Secret123!' }
    group { Group.find_or_create_by(name: 'FullAdmin') }
  end
end
