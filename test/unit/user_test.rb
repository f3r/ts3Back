require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "auto_signup" do
    should "create a new user account" do
      name = "Stewie Griffin"
      email = "ste@gmail.com"
      user = nil
      assert_difference 'User.count', +1 do
        user = User.auto_signup(name, email)
      end
      assert !user.new_record? # saved
      assert user.reset_password_token
      assert user.reset_password_sent_at
    end
  end
end
