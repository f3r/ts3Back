class CmspagesController < ApiController
  filter_access_to :all, :attribute_check => false
  respond_to :xml, :json

  # == Description
  # Returns the static page details based on page 
  # ==Resource URL
  # /cmspage.format
  # ==Example
  # GET https://backend-heypal.heroku.com/cmspage/content.json
  # === Parameters
  # [staticpage]
  # === Error codes
  # [115] No results
  def get_pagecontent
    @fields = [:id, :page_url, :page_title, :active , :description]
    if params[:pageurl]
      @pagecontents = Cmspage.where(:active => 1, :page_url => params[:pageurl]).first
    end

    if @pagecontents && !@pagecontents.blank?
      return_message(200, :ok, {:pagecontents => filter_fields(@pagecontents,@fields)})
    elsif @pagecontents && @pagecontents.blank?
      return_message(200, :ok, {:err => {:pagecontents => [115]}})
    else
      return_message(200, :fail, {:err => {:pagecontents => [101]}})
    end
  end
  
  # == Description
  # Returns the route details
  # ==Resource URL
  # /cmspage.format
  # ==Example
  # GET https://backend-heypal.heroku.com/staticpage/getdynamicroutes.json?active=1"
  # === Parameters
  # [active]
  # === Error codes
  # [115] No results
  
  def get_dynamicroutes
    @fields      = [:id, :page_url, :page_title,:route_as]
    @activeroute = Cmspage.active.select(@fields).all
    if @activeroute && !@activeroute.blank?
      return_message(200, :ok ,{:routedetails => filter_fields(@activeroute ,@fields)})
    elsif @activeroute && @activeroute.blank?
      return_message(200,:ok,{:err=>{:routedetails=>[115]}})
    else
      return_message(200,:fail,{:err=>{:routedetails=>[101]}})
    end
  end

end