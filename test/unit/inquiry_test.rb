require 'test_helper'

class InquiryTest < ActiveSupport::TestCase
  setup do
    without_access_control do
      @user = Factory(:user)
      @place = Factory(:published_place)
    end

    @emails = ActionMailer::Base.deliveries = []
  end

  def inquiry_params
    check_in = 1.month.from_now
    {
      :extra => {
        :name => 'Peter Griffin',
        :email => 'peter@quahog.com',
        :mobile => '+85 1234 5566'
      },
      :date_start => check_in.to_s,
      :length_stay => '2',
      :length_stay_type => 'months',
      :message => 'Pets allowed?'
    }
  end

  should "create_and_notify" do
    assert_difference 'Inquiry.count', +1 do
      Inquiry.create_and_notify(@place, @user, inquiry_params)
    end
    assert_equal 3, @emails.size
    inquiry = Inquiry.last
    assert_equal @user, inquiry.user
    assert_equal @place, inquiry.place
    assert_equal 2, inquiry.length_stay
    assert_equal 'months', inquiry.length_stay_type
  end

  should "create or continue a conversation" do
    assert_difference 'Conversation.count', +1 do
      Inquiry.create_and_notify(@place, @user, inquiry_params)
    end

    # The 2nd time it continues the previous conversation
    assert_difference 'Conversation.count', 0 do
      assert_difference 'Message.count', +1 do
        Inquiry.create_and_notify(@place, @user, inquiry_params)
      end
    end
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

      @inquiry.length = ['1', 'weeks']
      assert_equal '1 week', @inquiry.length_in_words

      @inquiry.length = ['1', 'bla']
      assert_nil @inquiry.length_in_words
    end
  end

  context "#transaction" do
    setup do
      @inquiry = Factory(:inquiry)
    end
    should "return a new transaction for an inquiry" do
      transaction = @inquiry.transaction
      assert transaction
      assert_equal @inquiry.user, transaction.user
      assert_equal @inquiry.place, transaction.place
      assert_equal @inquiry.check_in, transaction.check_in
      assert_equal @inquiry.check_out, transaction.check_out

      transaction2 = @inquiry.transaction
      assert_equal transaction, transaction2
    end
  end
end
