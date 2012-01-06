require 'test_helper'
class BankAccountsTest < ActionController::IntegrationTest

  setup do
    without_access_control do
      @admin = Factory(:user, :role => "admin")
      @admin.confirm!
      @agent = Factory(:user, :role => "agent")
      @agent.confirm!
      Authorization.current_user = @agent
      @fake_bank_account = { 
        :holder_street => Faker::Address.street_address,
        :holder_zip => Faker::Address.zip,
        :holder_city_name => Faker::Address.city
      }
    end
  end

  should "add bank_account as agent local country (json)" do
    assert_difference 'BankAccount.count', +1 do
      post "/users/me/bank_accounts.json", {
        :access_token => @agent.authentication_token, 
        :account_number => "12345", 
        :bank_code => "ABCD", 
        :branch_code => "ABCD",
        :holder_country_code => "SG" }.merge(@fake_bank_account)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @fake_bank_account[:holder_street], json['bank_account']['holder_street']
    assert_equal @fake_bank_account[:holder_zip], json['bank_account']['holder_zip']
  end

  should "add bank_account as agent not local country (json)" do
    assert_difference 'BankAccount.count', +1 do
      post "/users/me/bank_accounts.json", {
        :access_token => @agent.authentication_token, 
        :iban => "abcd", 
        :swift => "eerr1",
        :holder_country_code => "PA" }.merge(@fake_bank_account)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal @fake_bank_account[:holder_street], json['bank_account']['holder_street']
    assert_equal @fake_bank_account[:holder_zip], json['bank_account']['holder_zip']
  end

  should "add bank_account and update it as agent not local country (json)" do
    assert_difference 'BankAccount.count', +1 do
      post "/users/me/bank_accounts.json", {
        :access_token => @agent.authentication_token, 
        :iban => "abcd", 
        :swift => "eerr1",
        :holder_country_code => "PA"}.merge(@fake_bank_account)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    bank_account = BankAccount.first(:order => 'id DESC')
    put "/users/me/bank_accounts/#{bank_account.id}.json", {
      :access_token => @agent.authentication_token, 
      :holder_street => "testing",
      :holder_country_code => "PA",
      :holder_zip => "123"}
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    assert_equal "testing", json['bank_account']['holder_street']
    assert_equal "123", json['bank_account']['holder_zip']
  end

  should "add bank_account and delete it as agent not local country (json)" do
    assert_difference 'BankAccount.count', +1 do
      post "/users/me/bank_accounts.json", {
        :access_token => @agent.authentication_token, 
        :iban => "abcd", 
        :swift => "eerr1",
        :holder_country_code => "PA"}.merge(@fake_bank_account)
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    bank_account = BankAccount.first(:order => 'id DESC')
    assert_difference 'BankAccount.count', -1 do
      delete "/users/me/bank_accounts/#{bank_account.id}.json", {:access_token => @agent.authentication_token}
    end
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
  end

  # should "delete user bank_account as admin (json)" do
  #   assert_difference 'BankAccount.count', -1 do
  #     delete "/users/#{@agent.id}/bank_accounts/#{@bank_account.id}.json", {:access_token => @admin.authentication_token}
  #   end
  #   assert_response(200)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "ok", json['stat']
  # end
  # 
  # should "not delete admin bank_account as user (json)" do
  #   assert_difference 'BankAccount.count', 0 do
  #     delete "/users/#{@admin.id}/bank_accounts/#{@admin_bank_account.id}.json", {:access_token => @agent.authentication_token}
  #   end
  #   assert_response(404)
  #   assert_equal 'application/json', @response.content_type
  #   json = ActiveSupport::JSON.decode(response.body)
  #   assert_kind_of Hash, json
  #   assert_equal "fail", json['stat']
  # end
end