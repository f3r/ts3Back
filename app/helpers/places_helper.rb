module PlacesHelper
  def amenities_row(place)
    amenities = []
    Place.columns.select{|col| col.name =~ /amenities/}.each do |amenity_col|
      if place[amenity_col.name]
        amenities << amenity_col.name.gsub('amenities_', '')
      end
    end
    
    amenities.join(', ')
  end
end