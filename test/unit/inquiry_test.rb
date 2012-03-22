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
    assert_difference 'Inquiry.count', +1 do
      Inquiry.create_and_notify(@place, @user, {
        :extra => {
          :name => 'Peter Griffin',
          :email => 'peter@quahog.com',
          :mobile => '+85 1234 5566'
        },
        :date_start => check_in.to_s,
        :length_stay => '2',
        :length_stay_type => 'months',
        :message => 'Pets allowed?'
      })
    end
    assert_equal 3, @emails.size
    inquiry = Inquiry.last
    assert_equal @user, inquiry.user
    assert_equal @place, inquiry.place
    assert_equal check_in.to_date, inquiry.check_in
    assert_equal 2, inquiry.length_stay
    assert_equal 'months', inquiry.length_stay_type
  end

  context "#length=" do
    setup do
      @inquiry = Inquiry.new
      @inquiry.check_in = Date.today
    end

    should "support weeks" do
      @inquiry.length = ['1', 'weeks']
      assert_equal 1, @inquiry.length_stay
      assert_equal 'weeks', @inquiry.length_stay_type
      assert_equal 1.week.from_now.to_date, @inquiry.check_out
    end

    should "support 'more' length_stay" do
      @inquiry.length = ['more', 'months']
      assert_nil @inquiry.check_out
      assert_equal -1, @inquiry.length_stay
      assert_equal 'months', @inquiry.length_stay_type
    end

    should "show the length in words" do
      @inquiry.length = ['2', 'months']
      assert_equal '2 months', @inquiry.length_in_words

      @inquiry.length = ['1', 'week']
      assert_equal '1 week', @inquiry.length_in_words
    end
  end
end
