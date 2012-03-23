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

  # Add more helper methods to be used by all tests here...
end

require 'support/api_test_helpers'
class ActionController::IntegrationTest
  include ApiTestHelpers
end
