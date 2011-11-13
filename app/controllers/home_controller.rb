class HomeController < ApplicationController
  respond_to :xml, :json, :html
  def not_found
    return_message(404,:fail,{:err => {:record => [106]}})
  end
end