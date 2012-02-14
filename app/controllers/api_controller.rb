# All the controllers for the API should extend this base controller
class ApiController < ApplicationController
  filter_access_to :all, :attribute_check => false
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
end