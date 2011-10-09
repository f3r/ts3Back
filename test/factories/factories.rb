FactoryGirl.define do
  factory :user do
    email  { Faker::Internet.email }
    password { Faker::Lorem.words(2).to_sentence }
    password_confirmation { |u| u.password }
  end

  factory :category do
    name { Faker::Lorem.sentence(1) }
  end
end