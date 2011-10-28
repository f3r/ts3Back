FactoryGirl.define do
  factory :user do
    email  { Faker::Internet.email }
    first_name  { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    birthdate { Date.current - 20.year }
    password { Faker::Lorem.words(2).to_sentence }
    password_confirmation { |u| u.password }
  end

  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
    zip { Faker::Address.zip }
    user { @user }
  end

end