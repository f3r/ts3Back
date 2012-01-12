require 'money/bank/google_currency'
Money.default_bank = Money::Bank::GoogleCurrency.new

class PlacesController < ApplicationController
  filter_access_to :all, :attribute_check => false
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  before_filter :get_user, :only => [:user_places]
  
  def initialize
    @fields = [
      :id, :title, :description, :num_bedrooms, :num_beds, 
      :num_bathrooms, :size, :size_sqm, :size_sqf, :size_unit, :max_guests, :photos, :city_id, :address_1, 
      :address_2, :zip, :lat, :lon, :directions, 
      :check_in_after, :check_out_before, :minimum_stay, :stay_unit, 
      :maximum_stay, :house_rules, :cancellation_policy,
      :reviews_overall,:reviews_accuracy_avg,:reviews_cleanliness_avg,
      :reviews_checkin_avg,:reviews_communication_avg,:reviews_location_avg,
      :reviews_value_avg, :currency, :price_final_cleanup, 
      :price_security_deposit, :price_per_night, :price_per_week, :price_per_month,
      :published,
      :country_name, :country_code, :state_name, :city_name,
      :price_final_cleanup_usd, :price_security_deposit_usd, :price_per_night_usd, :price_per_week_usd, :price_per_month_usd
    ]
    
    @amenities = [
      :amenities_aircon,:amenities_breakfast,:amenities_buzzer_intercom,:amenities_cable_tv,
      :amenities_dryer,:amenities_doorman,:amenities_elevator,
      :amenities_family_friendly,:amenities_gym,:amenities_hot_tub,:amenities_kitchen,
      :amenities_handicap,:amenities_heating,:amenities_hot_water,
      :amenities_internet,:amenities_internet_wifi,:amenities_jacuzzi,:amenities_parking_included,
      :amenities_pets_allowed,:amenities_pool,:amenities_smoking_allowed,:amenities_suitable_events,
      :amenities_tennis,:amenities_tv,:amenities_washer  
    ]
    
    @search_fields = [
      :id, :title, :size_sqf, :size_sqm, :reviews_overall, :price_per_night_usd, :price_per_week_usd, :price_per_month_usd, :photos,
      :price_per_night, :price_per_week, :price_per_month, :currency
    ]

    @fields = @fields + @amenities

    # Associations
    @user_fields = [:id, :first_name, :last_name, :avatar_file_name, :role]
    @place_type_fields = [:id,:name]

    @transaction_fields = [
      :id, :state, :check_in, :check_out, :transaction_code,
      :currency, :price_per_night, :price_final_cleanup, :price_security_deposit, :service_fee, :service_percentage, :sub_total
    ]
    
    @place_details = [
      :title
    ]

  end

  # ==Description
  # Returns a list places matching the search parameters
  # ==Resource URL
  #   /places/search.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/search.json q[country_code_eq]=AU&q[num_bedrooms_lt]=5&q[num_bedrooms_gt]=2&page=1&m=and
  # === Matching options
  # [eq]
  #   Equal
  #     Ex: q[num_bedrooms_eq]=2
  # [not_eq]
  #   Not equal
  #     Ex: q[country_code_not_eq]=PH
  # [gt]
  #   Greater than
  #     Ex: q[num_bedrooms_gt]=4
  # [lt]
  #   Lower than
  #     Ex: q[num_bedrooms_lt]=2
  # [gteq]
  #   Greater than or equal
  #     Ex: q[num_bedrooms_gteq]=4
  # [lteq]
  #   Lower than or equal
  #     Ex: q[num_bedrooms_lteq]=4
  # [cont]
  #   Contains
  #     Ex: q[title_cont]=House
  # [true]
  #   True, 1 or 0
  #     Ex: q[amenities_washer_true]=1
  # [false]
  #   False, 1 or 0
  #     Ex: q[amenities_tv_false]=1
  # [present]
  #   Not empty, 1 or 0
  #     Ex: q[description_present]=1
  # [blank]
  #   Empty, 1 or 0
  #     Ex: q[description_present]=1
  # === Parameters
  # The search parameters are received as an array named "q", the paramater itself is composed by the name of the column and the matching option.
  # Do not use this search paramaters for published status.
  #   Ex: q[max_guests_eq]
  # [page]
  #   Page number
  #     Ex: page=2
  # [per_page]
  #   Results per page. Default is 20
  #     Ex: per_page=10
  # [m]
  #   Used to match all the parameters or any. Options: and, or.
  #     Ex: m=or
  # [status]
  #   Defaults to published, Options: published, not_published, all
  #     Ex: status=all
  # [guests]
  #   Defaults to 1, determines the number of guests against places.max_guests
  #     Ex: guests=3
  # [currency]
  #   Defaults to USD, ISO Code of the currency the user is searching
  #     Ex: currency=USD
  # [min_price]
  #   Defaults to 0, Minimum price per night for the apartment search in the currency selected (no cents)
  #     Ex: min_price=200
  # [max_price]
  #   Defaults to no maximum, Maximum price per night for the apartment search in the currency selected (no cents)
  #     Ex: max_price=600
  # [sort]
  #   Sorting options: name, price_lowest, price_highest, price_size_lowest, price_size_highest, reviews, most_recent
  #     Ex: sort=price_lowest
  # === Response
  # [results]      Total number of results. Used for pagination
  # [current_page] Current page number. Used for pagination
  # [per_page]     Results showed per page. Used for pagination
  # [total_pages]  Total number of pages. Used for pagination
  # [places]       Array containing the places
  # === Error codes
  # [115] no results
  def search
    !params[:per_page].blank? ? per_page = params[:per_page] : per_page = Place.per_page

    if !params[:q].blank?

      # Currency conversion
      if !params[:currency].blank? or params[:currency] != "USD"
        if params[:min_price]
          min_price = params[:min_price].to_money(params[:currency]).exchange_to(:USD).cents 
          params[:q].merge!({"price_per_night_usd_gteq" => "#{min_price}"})
        end
        if params[:max_price]
          max_price = params[:max_price].to_money(params[:currency]).exchange_to(:USD).cents if params[:max_price]
          params[:q].merge!({"price_per_night_usd_lteq" => "#{max_price}"})
        end
      # defaults to USD and checks against usd precalculated rates
      else
        params[:q].merge!({"price_per_night_usd_gteq" => "#{params[:min_price]}"}) if params[:min_price]
        params[:q].merge!({"price_per_night_usd_lteq" => "#{params[:max_price]}"}) if params[:max_price]
      end
      

      # Filter by number of guests
      if !params[:guests].blank?
        params[:q].merge!({"max_guests_gteq" => "#{params[:guests]}"})
      end
      
      places = Place.with_permissions_to(:read)
      
      # Filter by status
      case params[:status]
      when "all"
        @search = places.search(params[:q])
      when "published"
        @search = places.where(:published => true).search(params[:q])
      when "not_published"
        @search = places.where(:published => false).search(params[:q])
      else
        @search = places.where(:published => true).search(params[:q])
      end

      # Sorting column
      case params[:sort]
      when "name"
        sorting = ["title asc"]
      when "price_lowest"
        sorting = ["price_per_night_usd asc"]
      when "price_highest"
        sorting = ["price_per_night_usd desc"]
      when "price_size_lowest"
        sorting = ["price_sqf_usd asc"]
      when "price_size_highest"
        sorting = ["price_sqf_usd desc"]
      when "reviews_overall"
        sorting = ["reviews_overall desc"]
      when "most_recent"
        sorting = ["updated_at desc"]
      end

      @search.sorts = sorting if sorting
      places_search = @search.result(:distinct => true)
      total_results = places_search.count
      places_paginated = places_search.paginate(:page => params[:page], :per_page => per_page)

      if !places_paginated.blank?
        filtered_places = filter_fields(places_paginated, @search_fields, { :additional_fields => { 
          :user => @user_fields,
          :place_type => @place_type_fields },
        :currency => params[:currency]
        })

        place_types = PlaceType.all_cached

        place_type_count = {}
        for place_type in place_types
          count = 0
          for place in places_paginated
            count+=1 if place.place_type_id == place_type.id
          end
          place_type_count.merge!({place_type.name.parameterize(sep = '_').to_sym => count}) 
        end

        amenities_count = {}
        for amenity in @amenities
          count = 0
          for place in places_paginated
            count+=1 if place.send(amenity) == true
          end
          amenities_count.merge!({amenity.to_s.gsub("amenities_", "") => count}) 
        end

        response = {
          :places => filtered_places, 
          :results => total_results, 
          :per_page => per_page, 
          :current_page => params[:page], 
          :place_type_count => place_type_count,
          :amenities_count => amenities_count,
          :total_pages => (total_results/per_page.to_f).ceil
        }
      else
        response = {:err => {:places => [115]}}
      end
      return_message(200, :ok, response)
    else
      return_message(200, :ok, {:err => {:query => [101]}})
    end

  end

  # ==Description
  # Returns all the information about a place
  # ==Resource URL
  #   /places/:id.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/id.json
  # === Parameters
  # [id]         if of the place
  # [currency]   ISO Code of the currency to return prices in
  def show
    @place = Place.with_permissions_to(:read).find(params[:id])
    place = filter_fields(@place, @fields, { :additional_fields => { 
      :user => @user_fields,
      :place_type => @place_type_fields },
    :currency => params[:currency]})
    return_message(200, :ok, {:place => place})
  end
  
  # == Description
  # Crates a new place with basic information
  # ==Resource URL
  #   /places.format
  # ==Example
  #   POST https://backend-heypal.heroku.com/places.json access_token=access_token&title=Joe's Apartment&type_id=2&num_bedrooms=3&max_guests=5&city_id=62
  # === Parameters
  # [access_token] Access token
  # [title]         Title for the place
  # [place_type_id] ID from the PlaceType model, Integer
  # [num_bedrooms]  Integer
  # [max_guests]    Integer
  # [city_id]       ID from the City model, Integer
  # [currency]      Currency
  # === Response
  # [place] Array containing the recently created place
  # === Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [132] invalid city (not on the cities table)
  def create
    place = { 
      :title         => params[:title],
      :place_type_id => params[:place_type_id],
      :num_bedrooms  => params[:num_bedrooms],
      :max_guests    => params[:max_guests],
      :city_id       => params[:city_id],
      :currency      => params[:currency]}
    @place = current_user.places.new(place)
    if @place.save
      place_return = filter_fields(@place, [:id, :title,:num_bedrooms,:max_guests,:country_name, :country_code, :state_name, :city_name, :city_id, :currency], :additional_fields => {
          :user => @user_fields,
          :place_type => @place_type_fields
        })
      return_message(200, :ok, {:place => place_return})
    else
      return_message(200, :fail, {:err => format_errors(@place.errors.messages)})
    end
  end
  
  # == Description
  # Updates a place with additional information
  # ==Resource URL
  #   /places/:id.format
  # ==Example
  #   PUT https://backend-heypal.heroku.com/places/1.json access_token=access_token&num_beds=5&description=Nam luctus feugiat
  # === Parameters
  # [access_token] Access token
  # [title]         String,  title of the place
  # [description]   Text,    long description of the place
  # [place_type_id] Integer, ID from the PlaceType model
  # [num_bedrooms]  Integer, number of bedrooms
  # [num_beds]      Integer, number of beds
  # [num_bathrooms] Integer, number of bathrooms
  # [size]           Float,  square meters or square feet of the entire place
  # [size_unit]     String,  Size unit, feet or meters
  # [max_guests]    Integer, maximum number of guests the place can fit
  # [city_id]       Integer, ID from the Cities model
  # [address_1]     String,  text description of address
  # [address_2]     String
  # [zip]           String,  postal code
  # [lat]           Double,  latitude coordinates
  # [lon]           Double,  longitude coordinates
  # [directions]    Text,    description on how to find the place
  # [amenities_name]
  #   The following options are accepted (replace "name").
  #   aircon,breakfast,buzzer_intercom,cable_tv,dryer,doorman,elevator,
  #   family_friendly,gym,hot_tub,kitchen,handicap,heating,hot_water,
  #   internet,internet_wifi,jacuzzi,parking_included,pets_allowed,pool,
  #   smoking_allowed,suitable_events,tennis,tv,washer
  # [currency]               Currency ISO code, Ex. USD
  # [price_per_night]        Currency Units, not cents 1=$1, Integer
  # [price_per_week]         Currency Units, not cents 1=$1, Integer
  # [price_per_month]        Currency Units, not cents 1=$1, Integer
  # [price_final_cleanup]    Currency Units, not cents 1=$1, Integer
  # [price_security_deposit] Currency Units, not cents 1=$1, Integer
  # [check_in_after]         String, ie. 11:00 / 11:30 / 13:30
  # [check_out_before]       String, ie. 11:00 / 11:30 / 13:30
  # [minimum_stay]      Integer, 0 means no minimum
  # [maximum_stay]      Integer, 0 means no maximum
  # [stay_unit]         String, days, weeks or months
  # [house_rules]            Text, rules for the user to follow when staying at a place
  # [cancellation_policy]    Integer. Should align with frontend, 1=flexible, 2=moderate, 3=strict
  # 
  # === Response
  # [place] Array containing the recently created place
  # 
  # === Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [118] must be a number
  def update
    @place = Place.with_permissions_to(:read).find(params[:id])
    place = filter_params(params, @fields+[:place_type_id])
    if @place.update_attributes(place)
      place_return = filter_fields(@place,@fields, { :additional_fields => {
        :user => @user_fields,
        :place_type => @place_type_fields } })
      return_message(200, :ok, {:place => place_return})
    else
      return_message(200, :fail, {:err => format_errors(@place.errors.messages)})
    end
  end
  
  # == Description
  # Deletes a place
  # ==Resource URL
  #   /places/:id.format
  # ==Example
  #   DELETE https://backend-heypal.heroku.com/places/:id.json access_token=access_token
  # === Parameters
  # [access_token]
  def destroy
    place = Place.with_permissions_to(:read).find(params[:id])
    if place.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(place.errors.messages)})
    end
  end
  
  # == Description
  # Shows a users places
  # ==Resource URL
  #   /users/:id/places.format
  #   /users/me/places.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/users/:id/places.json access_token=access_token&status=any
  #   GET https://backend-heypal.heroku.com/users/me/places.json access_token=access_token&status=any
  # === Parameters
  # [access_token]  Access token
  # [status] Options: published, draft, any, Defaults to any
  # [currency]   ISO Code of the currency to return prices in
  # === Error codes
  # [115]           no results
  def user_places
    @places = @user.places.with_permissions_to(:read)
    case params[:status]
    when "published"
      @places = @places.where(:published => true)
    when "draft"
      @places = @places.where(:published => false)
    end
    if !@places.blank?
      places_return = filter_fields(@places,@fields, { :additional_fields => {
        :place_type => @place_type_fields},
        :currency => params[:currency]})
      return_message(200, :ok, {:places => places_return})
    else
      return_message(200, :ok, { :err => {:places => [115]}})
    end
  end

  # == Description
  # Changes a place status
  # ==Resource URL
  #   /places/:id/:status.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/:id/publish.json access_token=access_token
  #   GET https://backend-heypal.heroku.com/places/:id/unpublish.json access_token=access_token
  # === Parameters
  # [access_token]  Access token
  # [status]        Publish status, options: publish, unpublish
  # === Error codes
  # [106] Record not found
  # [123] not enough pictures
  # [124] description is too short
  # [126] no price
  # [127] no currency
  # [128] no security deposit
  def publish
    if params[:status] == "publish" or params[:status] == "unpublish"
      method = "#{params[:status]}!"
    else
      raise ActionController::UnknownAction
    end
    @place = Place.with_permissions_to(:read).find(params[:id])
      if method        
        if @place.send(method)
          place = filter_fields(@place,@fields, { 
            :additional_fields => {
              :place_type => @place_type_fields 
            } 
          })
          return_message(200, :ok, {:place => place})
        else
          return_message(200, :ok, { :err => format_errors(@place.errors.messages) })
        end
      else
        return_message(200, :ok, { :err => {:status => [103]} } )
      end
  end

  # == Description
  # Checks place availability
  # ==Resource URL
  #   /places/:id/check_availability.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/:id/check_availability.json access_token=access_token&check_in=2011/12/01&check_out=2012/01/03
  # === Parameters
  # [access_token]  Access token
  # [check_in]  Check in date
  # [check_out]  Check out date
  # [currency]   ISO Code of the currency to return prices in
  # === Response
  # [dates] Array containing the selected dates, with their respective price_per_night and comment if present
  # [total_days] total nights selected
  # [currency]
  # [avg_price_per_night] Average price_per_night, depending on availabilities special prices
  # [price_security_deposit]
  # [price_final_cleanup]
  # [sub_total] sum of price_per_night
  # === Error codes
  # [106] Record not found
  # [113] Invalid date
  # [119] date must be future, after today
  # [120] end date must be after initial date
  # [136] occupied
  def check_availability
    @place = Place.with_permissions_to(:read).find(params[:id])
    place_availability = @place.place_availability(params[:check_in], params[:check_out], params[:currency], current_user)
    if place_availability[:err].blank?
      return_message(200, :ok, place_availability)
    else
      return_message(200, :fail, place_availability)
    end
  end

  # == Description
  # Requests a place
  # ==Resource URL
  #   /places/:id/request.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/:id/request.json access_token=access_token
  # === Parameters
  # [access_token]  Access token
  # [check_in]  Check in date
  # [check_out]  Check out date
  # === Error codes
  # [106] Record not found
  # [137] invalid place request, check availability
  def place_request
    @place = Place.with_permissions_to(:read).find(params[:id])
    request = @place.place_availability(params[:check_in], params[:check_out], '', current_user)
    if request[:err].blank?  
      # TODO: store this elsewhere, create site settings
      service_percentage = 16
      service_fee = request[:sub_total] * (service_percentage * 0.01)
      transaction_data = {
        :user => current_user,
        :check_in => params[:check_in],
        :check_out => params[:check_out],
        :currency => request[:currency],
        :price_per_night => request[:avg_price_per_night],
        :price_final_cleanup => request[:price_final_cleanup],
        :price_security_deposit => request[:price_security_deposit],
        :service_fee => service_fee,
        :service_percentage => service_percentage,
        :sub_total => request[:sub_total]
      }
      transaction = @place.transactions.new(transaction_data)
      if transaction.save
        request_return = { 
          :transaction => filter_fields(
            transaction,
            @transaction_fields,
            { :additional_fields => {:user => @user_fields} }
          ) 
        }
        transaction.request!
        return_message(200, :ok, request_return)
      else
        return_message(200, :fail, {:err => format_errors(transaction.errors.messages)})
      end
    else
      return_message(200, :fail, :err=>{:place => [137]})
    end
  end

  # == Description
  # Shows place transactions
  # ==Resource URL
  #   /places/:id/transactions.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/:id/transactions.json access_token=access_token&status=active
  # === Parameters
  # [access_token]  Access token
  # [status] Options: active, inactive, any, Defaults to active
  # === Error codes
  # [106] Record not found
  # [115] no results
  def transactions
    place = Place.with_permissions_to(:manage).find(params[:id])

    case params[:status]
    when "active"
      transactions = place.transactions.active
    when "inactive"
      transactions = place.transactions.inactive
    when "any"
      transactions = place.transactions
    else
      transactions = place.transactions.active
    end
    
    if !transactions.blank?
      transactions_return = { 
        :transactions => filter_fields(
          transactions,
          @transaction_fields, { :additional_fields => {:user => @user_fields} }
        ) 
      }
      return_message(200, :ok, transactions_return)
    else
      return_message(200, :ok, {:err=>{:transactions => [115]}} )
    end
  end
  
  def confirm_rental
   @place = Place.with_permissions_to(:read).find(params[:place_id])
   RentalMailer.rental_confirmed_renter(@place.user, current_user, @place, params[:check_in], params[:check_out]).deliver
   RentalMailer.rental_confirmed_owner(@place.user, current_user, @place, params[:check_in], params[:check_out]).deliver
   RentalMailer.rental_confirmed_admin(@place.user, current_user, @place, params[:check_in], params[:check_out]).deliver
   return_message(200, :ok)
  end

  protected
  def get_user
    if params[:user_id] && params[:user_id].to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil # is numeric
      id = params[:user_id]
    elsif params[:user_id] == "me" && current_user
      id = current_user.id
    end
    @user = User.find(id) if id
  end

end