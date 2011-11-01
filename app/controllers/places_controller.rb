class PlacesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [
      :id, :title, :description, :num_bedrooms, :num_beds, 
      :num_bathrooms, :sqm, :max_guests, :photos, :city_id, :address_1, 
      :address_2, :zip, :lat, :lon, :directions, 
      :check_in_after, :check_out_before, :minimum_stay_days, 
      :maximum_stay_days, :house_rules, :cancellation_policy,
      :reviews_overall,:reviews_accuracy_avg,:reviews_cleanliness_avg,
      :reviews_checkin_avg,:reviews_communication_avg,:reviews_location_avg,
      :reviews_value_avg, :currency, :price_final_cleanup, 
      :price_security_deposit, :price_per_night, :price_per_week, :price_per_month,
      :published
    ]

    @location_fields = [:country_id, :state_id, :city_id, :address_1, :address_2, :zip, :lat, :lon, :directions]

    @amenities_fields = [:aircon,:breakfast,:buzzer_intercom,:cable_tv,:dryer,:doorman,:elevator,
      :family_friendly,:gym,:hot_tub,:kitchen,:handicap,:heating,:hot_water,
      :internet,:internet_wifi,:jacuzzi,:parking_included,:pets_allowed,:pool,
      :smoking_allowed,:suitable_events,:tennis,:tv,:washer]

    @reviews_fields = [
      :overall,:accuracy_avg,:cleanliness_avg,
      :checkin_avg,:communication_avg,:location_avg,
      :value_avg
    ]
    
    @terms_of_offer_fields = [
      :check_in_after, :check_out_before, :minimum_stay_days, :maximum_stay_days, :house_rules,
      :cancellation_policy
    ]

    @pricing_fields = [
      :price_final_cleanup, :price_security_deposit, :price_per_night, :price_per_week, :price_per_month, :currency,
      :price_final_cleanup_usd, :price_security_deposit_usd, :price_per_night_usd, :price_per_week_usd, :price_per_month_usd
    ]

    @details_fields = [
      :num_bedrooms, :num_beds, :num_bathrooms, :sqm, :max_guests, :title, :description
    ]

    # Assosiations
    @user_fields = [:id, :first_name, :last_name, :avatar_file_name]
    @place_type_fields = [:id,:name]

  end

  def search
  end

  # ==Description
  # Returns all the information about a place
  # ==Resource URL
  # /places/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/places/id.json
  # === Parameters
  # [:id] if of the place
  def show
    @place = Place.find(params[:id])
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :place => filter_fields(@place, @fields, { :additional_fields => { 
            :amenities => @amenities_fields, 
            :location => @location_fields, 
            :reviews => @reviews_fields,
            :terms_of_offer => @terms_of_offer_fields,
            :pricing => @pricing_fields,
            :details => @details_fields,
            :user => @user_fields,
            :place_type => @place_type_fields } }) },
          request.format.to_sym) }
    end
  end
  
  # == Description
  # Crates a new place with basic information
  # ==Resource URL
  # /places.format
  # ==Example
  # POST https://backend-heypal.heroku.com/places.json access_token=access_token&title=Joe's Apartment&type_id=2&num_bedrooms=3&max_guests=5&city_id=62
  # === Parameters
  # [:access_token] Access token
  # [title]         Title for the place
  # [place_type_id] ID from the PlaceType model, Integer
  # [num_bedrooms]  Integer
  # [max_guests]    Integer
  # [city_id]       ID from the City model, Integer
  # === Response
  # [place] Array containing the recently created place
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  def create
    check_token
    place = { 
      :title => params[:title],
      :place_type_id => params[:place_type_id],
      :num_bedrooms => params[:num_bedrooms],
      :max_guests => params[:max_guests],
      :city_id => params[:city_id] }
    @place = current_user.places.new(place)
    respond_with do |format|
      if @place.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :place => filter_fields(@place, [:id], :additional_fields => {
                :details => [:title,:num_bedrooms,:max_guests],
                :location => [:city_id],
                :user => @user_fields,
                :place_type => @place_type_fields
              }) },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@place.errors.messages) },
          request.format.to_sym)}
      end
    end
  end
  
  # == Description
  # Updates a place with additional information
  # ==Resource URL
  # /places/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/places/1.json access_token=access_token&num_beds=5&description=Nam luctus feugiat
  # === Parameters
  # [:access_token] Access token
  # [title]         String,  title of the place
  # [description]   Text,    long description of the place
  # [place_type_id] Integer, ID from the PlaceType model
  # [num_bedrooms]  Integer, number of bedrooms
  # [num_beds]      Integer, number of beds
  # [num_bathrooms] Integer, number of bathrooms
  # [sqm]           Float,   square meters of the entire place
  # [max_guests]    Integer, maximum number of guests the place can fit
  # [city_id]       Integer, ID from the Cities model
  # [address_1]     String,  text description of address
  # [address_2]     String
  # [zip]           String,  postal code
  # [lat]           Double,  latitude coordinates
  # [lon]           Double,  longitude coordinates
  # [directions]    Text,    description on how to find the place
  # [amenities]
  #   Array of boolean values with the following options.
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
  # [minimum_stay_days]      Integer, 0 means no minimum
  # [maximum_stay_days]      Integer, 0 means no maximum
  # [house_rules]            Text, rules for the user to follow when staying at a place
  # [cancellation_policy]    Integer. Should align with frontend, 1=flexible, 2=moderate, 3=strict
  # 
  # === Response
  # [place] Array containing the recently created place
  # 
  # == Error codes
  # [101] can't be blank 
  # [103] is invalid
  # [105] invalid access token
  # [118] must be a number
  def update
    check_token
    @place = Place.find(params[:id])
    [:price_per_night, :price_per_week, :price_per_month, :price_final_cleanup, :price_security_deposit, :currency, :amenities].map{|x| @fields << x}
    place = filter_params(params, @fields)
    respond_with do |format|
      if @place.update_attributes(place)
        # remove from array private fields
        [:price_per_night, :price_per_week, :price_per_month, :price_final_cleanup, :price_security_deposit, :currency].map{|x| @fields.delete(x) }
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :place => filter_fields(@place,@fields, { :additional_fields => {
              :amenities => @amenities_fields, 
              :location => @location_fields, 
              :reviews => @reviews_fields,
              :terms_of_offer => @terms_of_offer_fields,
              :pricing => @pricing_fields,
              :details => @details_fields,
              :user => @user_fields,
              :place_type => @place_type_fields } }) },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@place.errors.messages) },
          request.format.to_sym)}
      end
    end
  end
  
  # == Description
  # Deletes a place
  # ==Resource URL
  # /places/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/places/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    place = Place.find(params[:id])
    respond_with do |format|
      if place.destroy
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok" },
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(place.errors.messages) },
          request.format.to_sym) }
      end
    end
  end
  
end