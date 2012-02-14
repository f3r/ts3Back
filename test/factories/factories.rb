FactoryGirl.define do

  factory :user do
    email                 { Faker::Internet.email }
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    birthdate             { Date.current - 20.year }
    password              { Faker::Lorem.words(2).to_sentence }
    password_confirmation { |u| u.password }
    confirmed_at          { 1.day.ago }
  end

  factory :address do
    street  { Faker::Address.street_address }
    city    { Faker::Address.city }
    country { Faker::Address.country }
    zip     { Faker::Address.zip }
    user    { @user }
  end

  factory :bank_account do
    holder_name           { Faker::Name.name }
    holder_street         { Faker::Address.street_address }
    holder_zip            { Faker::Address.zip }
    holder_city_name      { Faker::Address.city }
    holder_country_name   { Faker::Address.country }
    holder_country_code   { Faker::Address.country_code }
    user                  { @user }
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
    currency     { "JPY"}
    amenities_tv { true }
  end
  
  factory :published_place, :class => Place do
    title        { Faker::Lorem.words(2).to_sentence }
    description  { Faker::Lorem.paragraph }
    address_1    { Faker::Address.street_address }
    address_2    { Faker::Address.secondary_address }
    zip          { Faker::Address.zip }
    city
    num_bedrooms { 2 }
    max_guests   { 4 }
    place_type
    user
    currency     { "JPY"}
    amenities_tv { true }
    published    { true }
    size_unit    { 'meters' }
    size         { 100 }
    price_per_month  { 400000 }
    photos       { [{:url => "http://example.com/luke.jpg",:description => "Luke"}, {:url => "http://example.com/yoda.jpg",:description => "Yoda"}, {:url => "http://example.com/darthvader.jpg",:description => "Darth Vader"}].to_json }
    user         { @user }
    currency     { "JPY"}
    amenities_tv { true }
  end
  
  factory :comment do
    place     { @place }
    user      { @user  }
    comment   { Faker::Lorem.paragraph }
  end
  
  factory :availability do
    place               { @place }
    availability_type   { 2 } # new price
    date_start          "#{(Date.current + 2.year + 1.day).to_s}"
    date_end            "#{(Date.current + 2.year + 15.day).to_s}"
    comment             "new comment"
  end

  factory :city do
    name              { "Chicago" }
    state             { "Illinois" }
    country           { "United States" }
    country_code      { "US" }
  end
  
  factory :photo do
    photo ActionController::TestCase.fixture_file_upload('test/fixtures/test_image.jpg', 'image/jpg')
  end

end