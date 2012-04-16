require 'test_helper'
class TransactionsControllerTest < ActionController::TestCase
  setup do
    @request.accept = 'application/json'
    @guest   = Factory(:user, :role => "user")
    @agent   = Factory(:user, :role => "agent")
    @place   = Factory(:published_place, :user => @agent)
    @inquiry = Factory(:inquiry, :place => @place, :user => @guest)
    @transaction = @inquiry.transaction
  end

  context 'workflow' do
    should "start with a transaction on initial state" do
      assert_equal "initial", @transaction.state
    end

    should 'transition to requested' do
      put :update, :id => @inquiry.id, :event => 'request', :access_token => @guest.authentication_token
      json = assert_ok
      assert_equal 'requested', json['inquiry']['state']
    end

    should 'transition to ready_to_pay' do
      @transaction.update_attribute(:state, 'requested')
      put :update, :id => @inquiry.id, :event => 'pre_approve', :access_token => @agent.authentication_token
      json = assert_ok
      assert_equal 'ready_to_pay', json['inquiry']['state']
    end

    should 'transition to paid' do
      @transaction.update_attribute(:state, 'ready_to_pay')
      put :update, :id => @inquiry.id, :event => 'pay', :access_token => @guest.authentication_token
      json = assert_ok
      assert_equal 'paid', json['inquiry']['state']
    end

    should 'not allow user to request a transaction from another user' do
      @guest2 = Factory(:user, :role => "user")
      assert_raise Workflow::TransitionHalted  do
        put :update, :id => @inquiry.id, :event => 'request', :access_token => @guest2.authentication_token
      end
    end

    should 'not allow agent to pre-approve a transaction from another user' do
      @transaction.update_attribute(:state, 'requested')
      @agent2 = Factory(:user, :role => "agent")
      assert_raise Workflow::TransitionHalted  do
        put :update, :id => @inquiry.id, :event => 'pre_approve', :access_token => @agent2.authentication_token
      end
    end
  end
end