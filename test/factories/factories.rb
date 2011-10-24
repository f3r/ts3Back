FactoryGirl.define do
  factory :user do
    email  { Faker::Internet.email }
    name  { Faker::Name.name }
    birthdate { Date.current - 20.year }
    password { Faker::Lorem.words(2).to_sentence }
    password_confirmation { |u| u.password }
  end

  factory :category do
    name { Faker::Lorem.sentence(1) }
  end

  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
    zip { Faker::Address.zip }
    user { @user }
  end

end