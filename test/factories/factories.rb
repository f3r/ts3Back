FactoryGirl.define do

  factory :user do
    email                 { Faker::Internet.email }
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    birthdate             { Date.current - 20.year }
    password              { Faker::Lorem.words(2).to_sentence }
    password_confirmation { |u| u.password }
  end

  factory :address do
    street  { Faker::Address.street_address }
    city    { Faker::Address.city }
    country { Faker::Address.country }
    zip     { Faker::Address.zip }
    user    { @user }
  end

  factory :place_type do
    name { Faker::Lorem.words(2).to_sentence }
  end

  factory :place do
    title        { Faker::Lorem.words(2).to_sentence }
    description  { Faker::Lorem.paragraph }
    address_1    { Faker::Address.street_address }
    address_2    { Faker::Address.secondary_address }
    zip          { Faker::Address.zip }
    city_id      { 1 }
    num_bedrooms { 2 }
    max_guests   { 4 }
    place_type   { @place_type }
    user         { @user }
  end
  
  factory :country do
    code_iso  { "US" }
    name      { "United States" }
    capital   { "Washington" }
  end

  factory :state do
    geo_country_code      { "US" }
    geo_name              { "Illinois" }
    geo_admin1_code       { "IL" }
    geo_alternate_names   { "Illinois" }
    geo_ansiname          { "Illinois" }
  end

  factory :city do
    geo_country_code      { "US" }
    geo_name              { "Chicago" }
    geo_admin1_code       { "IL" }
    geo_alternate_names   { "Chicago" }
    geo_ansiname          { "Chicago" }
  end

end