require 'test_helper'

class InquiryTest < ActiveSupport::TestCase
  setup do
    without_access_control do
      @user = Factory(:user)
      @place = Factory(:published_place)
    end

    @emails = ActionMailer::Base.deliveries = []
  end
  
  test "create_and_notify" do
    check_in = 1.month.from_now
    check_out = check_in + 1.month
    assert_difference 'Inquiry.count', +1 do
      Inquiry.create_and_notify(@place, @user, check_in, check_out, {
        :name => 'Peter Griffin',
        :email => 'peter@quahog.com',
        :mobile => '+85 1234 5566',
        :questions => 'Pets allowed?'
      })
    end
    
    assert_equal 3, @emails.size
  end
end
