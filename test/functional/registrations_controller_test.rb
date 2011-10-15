require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

test "should sign up regular user without oauth token (json)" do
  assert_difference('User.count') do
    post :create, name: Faker::Name.name, 
                  :email => Faker::Internet.email, 
                  :password => "testing", 
                  :format => :json
  end
  assert_response(200)
end

test "should sign up regular user without oauth token (xml)" do
  assert_difference('User.count') do
    post :create, name: Faker::Name.name, 
                  :email => Faker::Internet.email, 
                  :password => "testing", 
                  :format => :xml
  end
  assert_response(200)
end

# test "should sign up with oauth token (json)" do
#   assert_difference('User.count') do
#     post :create, :name Faker::Name.name, 
#                   :email => Faker::Internet.email, 
#                   :password => "testing", 
#                   :format => :json, 
#                   :oauth_token => {}
#   end
#   assert_response(200)
# end


end