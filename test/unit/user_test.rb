require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should validate_presence_of :email

  should_not allow_value("blah").for(:email)

  # test "should authenticate with matching username and password" do
  # 
  #   @user = Factory(:user)
  #   sign_in @user
  #   # @user = Factory(:user, :email => 'user@example.com', :password => 'secret')
  #   # Warden.authenticate @user
  #   # User.authenticate(:email => 'user@example.com', :password => 'secret').should == user
  # end
  # 
  # test "should not authenticate with incorrect password" do
  #   user = Factory(:user)
  #   User.authenticate(:email => 'user@example.com', :password => 'el_secret').should == user
  # end

end
