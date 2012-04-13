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
    photos       { 3.times.collect{ p = Photo.new; p.save(:validate => false); p } }
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
    name   { Faker::Name.name }
    photo  ActionController::TestCase.fixture_file_upload('test/fixtures/test_image.jpg', 'image/jpg')
    #association :place, :factory => :valid_place
  end

  factory :alert do
    schedule  { "daily" }
    alert_type  { "Place" }
    delivery_method    { "sms" }
    query { {:hello => "hello", :bye => "bye"} }
  end

  factory :message do
    association :from, :factory => :user
    body        { Faker::Lorem.paragraph }
  end

  factory :conversation do
    messages    { [Factory.create(:message)] }
    sender      { |c| c.messages.first.from }
  end

  factory :inbox_entry do
    conversation
  end

  factory :inquiry do
    user
    association :place, :factory => :published_place
    check_in    { Date.current + 2.year + 1.day }
    check_out   { Date.current + 2.year + 1.month }
  end
end