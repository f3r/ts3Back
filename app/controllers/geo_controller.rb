class GeoController < ApplicationController
  respond_to :xml, :json
  
  # TODO: Check caching, it seems to be buggy

  # == Description
  # Returns a list of all the countries
  # ==Resource URL
  # /geo/countries.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/countries.json
  # ==Response
  # id, code_iso and name
  def get_countries
    @countries = Rails.cache.fetch('geo_countries_list') {
      City.find_by_sql(["SELECT DISTINCT country, country_code FROM cities ORDER BY country"])
    }
    return_message(200, :ok, {:countries => @countries})
  end

  # == Description
  # Returns a list of all the states on a country, accepts country_code
  # ==Resource URL
  # /geo/states.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/states.json country_code=PA
  # === Parameters
  # [country_code]
  # Error codes
  # [115] no results
  def get_states
    @states = Rails.cache.fetch('geo_states_' + params[:country_code].to_s) { 
      City.find_by_sql(["SELECT DISTINCT state FROM cities WHERE country_code = ? ORDER BY state", params[:country_code]])
    }
    if !@states.blank?
      return_message(200, :ok, { :states => @states })
    else
      return_message(200, :ok, { :err => {:states => [115]} })
    end
  end

  # == Description
  # Returns a list of all the cities on a state, accepts country_code
  # ==Resource URL
  # /geo/cities.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/cities.json country_code=SG
  # === Parameters
  # [country_code]
  # [state]
  # === Error codes
  # [115] No results
  def get_cities
    country_code = params[:country_code] if params[:country_code]
    state = params[:state] if params[:state]
    @fields = [:id, :name, :lat, :lon]
    if country_code
      @cities = Rails.cache.fetch('geo_cities_' + country_code) { 
        City.select(@fields).where(:country_code => country_code).all
      }
    elsif state
      @cities = Rails.cache.fetch('geo_cities_' + state.parameterize) { 
        City.select(@fields).where(:state => state).all
      }
    end
    if @cities && !@cities.blank?
      return_message(200, :ok, {:states => filter_fields(@cities,@fields)})
    elsif @cities && @cities.blank?
      return_message(200, :ok, {:err => {:cities => [115]}})
    else
      return_message(200, :fail, {:err => {:country_code => [101]}})
    end
  end

  # == Description
  # Returns a city
  # ==Resource URL
  # /geo/cities/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/cities/1.json
  # === Parameters
  # [id]
  # === Error codes
  # [106] Record not found
  def get_city
    @fields = [:id, :name, :lat, :lon, :state, :country, :country_code]
    @city = Rails.cache.fetch('geo_cities_' + params[:id].parameterize) { 
      City.select(@fields).find(params[:id])
    }
    return_message(200, :ok, {:city => @city})
  end

end