class GeoController < ApplicationController
  respond_to :xml, :json

  # == Description
  # Returns a list of all the countries
  # ==Resource URL
  # /geo/countries.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/countries.json
  def get_countries
    @countries = Rails.cache.fetch('countries_all') { 
      Country.select("id, code_iso as country_code, name").all
    }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :countries => @countries },
        request.format.to_sym) }
    end
  end

  # == Description
  # Returns a list of all the states on a country
  # ==Resource URL
  # /geo/states.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/states.json country_id=1
  # === Parameters
  # [country_id]
  def get_states
    country_id = params[:country_id]
    @fields = [:id, :geo_name, :geo_latitude, :geo_longitude]
    @states = Rails.cache.fetch('states_' + country_id.to_s) { 
      State.where(["states.geo_country_code = countries.code_iso AND countries.id = ?", country_id]).
            select("states.id as id, states.geo_name as name, states.geo_latitude as lat, states.geo_longitude as lon").
            joins(:country)
    }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :states => @states },
        request.format.to_sym) }
    end
  end

  # == Description
  # Returns a list of all the cities on a state
  # ==Resource URL
  # /geo/cities.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/cities.json state_id=3
  # === Parameters
  # [state_id]
  def get_cities
    state_id = params[:state_id]
    @cities = Rails.cache.fetch('cities_' + state_id) { 
      City.find_by_sql(["SELECT cities.id as id, cities.geo_name as name, cities.geo_latitude as lat, cities.geo_longitude as lon " +
      "FROM cities, states " +
      "WHERE states.geo_country_code = cities.geo_country_code " +
      "AND states.geo_admin1_code = cities.geo_admin1_code " +
      "AND states.id = ?", state_id
      ])
    }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :cities => @cities },
        request.format.to_sym) }
    end
  end

  # == Description
  # Returns a city
  # ==Resource URL
  # /geo/cities/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/cities/1.json
  # === Parameters
  # [city_id]
  def get_city
    city_id = params[:id]
    @fields = [:id, :geo_name, :geo_latitude, :geo_longitude]
    @city = Rails.cache.fetch('cities_' + city_id) { 
      City.select("id, geo_name as name, geo_latitude as lat, geo_longitude as lon").find(city_id)
    }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :city => @city },
        request.format.to_sym) }
    end
  end

end