FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@geekvoice.com" }
    password "foobar"
    password_confirmation { |u| u.password }
    sequence(:authentication_token) { |n| "testing#{n}" }
  end

  factory :category do
    sequence(:name) { |n| "Category#{n}" }
  end
end