ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

include ActionDispatch::TestProcess
require 'action_dispatch/testing/test_process'

require 'shoulda'
require 'factory_girl'
FactoryGirl.find_definitions

require 'declarative_authorization/maintenance'
include Authorization::TestHelper

# All the factories ignore access control
module FactoryGirl
  module Syntax
    module Methods
      alias_method :original_create, :create

      def create(name, *traits_and_overrides, &block)
        without_access_control do
          original_create(name, *traits_and_overrides, &block)
        end
      end
    end
  end
end

require 'action_dispatch/testing/test_process'
include ActionDispatch::TestProcess

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  include Authorization::TestHelper
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end

  def assert_ok
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = json_response
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    json
  end

  def json_response_ok
    assert_ok
  end

  def assert_fail
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = json_response
    assert_kind_of Hash, json
    assert_equal "fail", json['stat']
    json
  end
end

require 'support/api_test_helpers'
class ActionController::IntegrationTest
  include ApiTestHelpers
end
