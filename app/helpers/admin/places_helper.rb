module Admin::PlacesHelper
  def public_place_path(place)
    frontend_url("/places/#{place.id}")
  end
  
  def place_links_column(place)
    html = link_to('Details', admin_place_path(place), :class => 'member_link')
    html << link_to('Edit', edit_admin_place_path(place), :class => 'member_link')
    html << link_to_if(place.published, 'View Public', public_place_path(place), :class => 'member_link', :target => '_blank')
  end
  
  def place_amenities_row(place)
    amenities = []
    Place.columns.select{|col| col.name =~ /amenities/}.each do |amenity_col|
      if place[amenity_col.name]
        amenities << amenity_col.name.gsub('amenities_', '')
      end
    end
    
    amenities.join(', ')
  end
  
  def place_photos_row(place)
    return unless place.photos
    place.photos.collect do |record|
      photo = record.photo
      link_to image_tag(photo.url(:small)), photo.url, :target => '_blank'
    end.join(' ').html_safe
  end
end