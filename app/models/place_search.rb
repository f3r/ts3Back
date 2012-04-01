class PlaceSearch
  def initialize(user, params)
    @user = user
    @params = params
  end

  def search(ignore_filters = [])
    add_base_conditions
    add_filter_conditions(ignore_filters)
    add_order
  end

  def results
    unless @results
      search
      @results = results_with_pagination
    end

    @results
  end

  def all_results(ignore_filters = [])
    search(ignore_filters)
    results_without_pagination
  end

  def all_results_ids
    all_results.map(&:id)
  end

  def count_results
    @search.result(:distinct => true).count
  end

  def per_page
    params[:per_page] || Place.per_page
  end

  def place_type_counts
    place_types = PlaceType.all_cached
    places = all_results([:place_type_id_eq_any]).to_a
    place_type_count = {}
    place_types.each do |place_type|
      count = places.count{|place| place.place_type_id == place_type.id}
      place_type_count[place_type.name.parameterize(sep = '_').to_sym] = count
    end

    place_type_count
  end
  
  def amenities_counts
    # amenities_count = {}
    # for amenity in @amenities
    #   count = 0
    #   for place in places_paginated
    #     count+=1 if place.send(amenity) == true
    #   end
    #   amenities_count[amenity.to_s.gsub("amenities_", "")] = count
    # end
  end

  def valid?
    # City id is required
    return false unless city_id
    return true
  end

  protected

  def add_base_conditions
    all_places = Place.with_permissions_to(:read)

    # Filter by status
    case params[:status]
    when "all"
      places = all_places
    when "not_published"
      places = all_places.where(:published => false)
    else
      places = all_places.where(:published => true)
    end

    # Filter by City
    places = places.where(:city_id => city_id)

    @source = places
  end

  def add_filter_conditions(ignore_filters = [])
    conditions = prepare_conditions

    ignore_filters.each do |filter|
      conditions.delete(filter)
    end

    # Filter by conditions
    @search = @source.search(conditions)
  end

  def add_order
    # Sorting column
    sort_map = {
      "name"               => "title asc",
      "price_lowest"       => "price_per_month_usd asc",
      "price_highest"      => "price_per_month_usd desc",
      "price_size_lowest"  => "price_sqf_usd asc",
      "price_size_highest" => "price_sqf_usd desc",
      "reviews_overall"    => "reviews_overall desc",
      "most_recent"        => "updated_at desc"
    }

    sorting = sort_map[params[:sort]]

    @search.sorts = sorting if sorting
  end

  def results_with_pagination
    @search.result(:distinct => true).paginate(:page => params[:page], :per_page => per_page)
  end

  def results_without_pagination
    @search.result(:distinct => true)
  end

  def prepare_conditions
    conditions = {}

    conditions.merge!(params[:q].symbolize_keys) if params[:q]

    # Currency conversion
    if params[:currency].blank? ##|| params[:currency] == "USD"
      # defaults to USD and checks against usd precalculated rates
      conditions[:price_per_month_usd_gteq] = params[:min_price] if params[:min_price]
      conditions[:price_per_month_usd_lteq] = params[:max_price] if params[:max_price]
    else
      if params[:min_price]
        min_price = params[:min_price].to_money(params[:currency]).exchange_to(:USD).cents
        conditions[:price_per_month_usd_gteq] = min_price
      end
      if params[:max_price]
        max_price = params[:max_price].to_money(params[:currency]).exchange_to(:USD).cents if params[:max_price]
        conditions[:price_per_month_usd_lteq] = max_price
      end
    end

    # Filter by number of guests
    conditions[:max_guests_gteq] = params[:guests] if !params[:guests].blank?

    # Filter by date
    conditions[:created_at_gteq] = params[:date_from] if !params[:date_from].blank?    

    # exclude places
    conditions[:id_not_in] = params[:exclude_ids] if !params[:exclude_ids].blank?    

    # Filter by availability
    if params[:check_in]
      check_in = params[:check_in].to_date
      if params[:check_out]
        check_out = params[:check_out].to_date
      else
        check_out = check_in + 1.month # default one month
      end
    end

    if check_in && check_out
      unavailable_places = []
      @source.each do |place|
        place_availability = place.place_availability(check_in, check_out, params[:currency], @user)
        if place_availability[:err]
          unavailable_places << place
        end
      end
      unavailable_place_ids = unavailable_places.map(&:id)
      conditions[:id_not_in] = unavailable_place_ids unless unavailable_place_ids.blank?
    end

    conditions
  end

  def params
    @params
  end

  def city_id
    params[:city] || params[:city_id]
  end
end