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
    @countries = Rails.cache.fetch('geo_countries_list') { Country.select([:id, :code_iso, :name]).all }
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
  # Returns a list of all the states on a country, accepts country_code *OR* country_id
  # ==Resource URL
  # /geo/states.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/states.json country_id=1
  # === Parameters
  # [country_id]
  # [country_code]
  # Error codes
  # [115] no results
  def get_states
    country_id = params[:country_id] if params[:country_id]
    country_code = params[:country_code] if params[:country_code]
    @fields = [:id, :name, :lat, :lon]
    if country_id
      @states = Rails.cache.fetch('geo_states_' + country_id.to_s) { 
        State.select("states.id as id, states.geo_name as name, states.geo_latitude as lat, states.geo_longitude as lon")
        .joins(:country)
        .where(["states.geo_country_code = countries.code_iso AND countries.id = ?", country_id])
        .all
      }
    elsif country_code
      @states = Rails.cache.fetch('geo_states_' + country_code.to_s) { 
        State.select("states.id as id, states.geo_name as name, states.geo_latitude as lat, states.geo_longitude as lon")
        .joins(:country)
        .where(["states.geo_country_code = countries.code_iso AND countries.code_iso = ?", country_code])
        .all
      }
    end
    respond_with do |format|
      if !@states.empty?
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :states => filter_fields(@states,@fields) },
          request.format.to_sym)
        }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :err => {:states => [115]} },
          request.format.to_sym)
        }
      end
    end
  end

  # == Description
  # Returns a list of all the cities on a state, accepts country_code *OR* state_id *OR* country_id
  # ==Resource URL
  # /geo/cities.format
  # ==Example
  # GET https://backend-heypal.heroku.com/geo/cities.json state_id=3
  # === Parameters
  # [state_id]
  # [country_id]
  # [country_code]
  # === Error codes
  # [115] No results
  def get_cities
    state_id = params[:state_id] if params[:state_id]
    country_code = params[:country_code] if params[:country_code]
    country_id = params[:country_id] if params[:country_id]
    @fields = [:id, :name, :lat, :lon]
    if state_id
      @cities = Rails.cache.fetch('geo_cities_' + state_id) { 
        City.find_by_sql(["SELECT cities.id as id, cities.geo_name as name, cities.geo_latitude as lat, cities.geo_longitude as lon " +
        "FROM cities, states " +
        "WHERE states.geo_country_code = cities.geo_country_code " +
        "AND states.geo_admin1_code = cities.geo_admin1_code " +
        "AND states.id = ?", state_id
        ])
      }
    elsif country_code
      @cities = Rails.cache.fetch('geo_cities_' + country_code) { 
        City.where(:geo_country_code => country_code).select("id, geo_name as name, geo_latitude as lat, geo_longitude as lon").all
      }
    elsif country_id
      @cities = Rails.cache.fetch('geo_cities_' + country_id) { 
        City.find_by_sql(["SELECT cities.id as id, cities.geo_name as name, cities.geo_latitude as lat, cities.geo_longitude as lon " +
        "FROM cities, countries " +
        "WHERE cities.geo_country_code = countries.code_iso " +
        "AND countries.id = ?", country_id
        ])
      }
    end
    respond_with do |format|
      if !@cities.empty?
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :states => filter_fields(@cities,@fields) },
          request.format.to_sym)
        }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :err => {:cities => [115]} },
          request.format.to_sym)
        }
      end
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
  # === Error codes
  # [106] Record not found
  def get_city
    city_id = params[:id]
    @fields = [:id, :name, :lat, :lon]
    @city = Rails.cache.fetch('geo_cities_' + city_id) { 
      City.select("id, geo_name as name, geo_latitude as lat, geo_longitude as lon, geo_country_code, geo_admin1_code").find(city_id)
    }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :city => filter_fields(@city, @fields, { 
            :additional_fields => { 
              :state => [:id, :name],
              :country => [:id, :name, :code_iso]
            } 
        }) },
        request.format.to_sym) }
    end
  end

end