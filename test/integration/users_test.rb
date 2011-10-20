require 'test_helper'
class UsersTest < ActionController::IntegrationTest

  setup do
    @parameters = { :name => Faker::Name.name, 
                    :email => Faker::Internet.email, 
                    :password => "FSls26ESKaaJzADP" }
  end


end