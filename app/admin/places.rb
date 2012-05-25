ActiveAdmin.register Place do
  menu :priority => 2

  controller do
    helper 'admin/places'
  end

  scope :all, :default => true
  scope :published
  scope :unpublished

  filter :title
  filter :user
  filter :city
  filter :created_at

  index do
    id_column
    column :title
    column :user
    column :city
    column :created_at
    column :updated_at
    column("Status")      {|place| status_tag(place.published ? 'Published' : 'Unpublished') }
    column("Actions")     {|place| place_links_column(place) }
  end

  show do
    rows = default_attribute_table_rows.reject {|a| a =~ /photos|amenities|review/}
    attributes_table *rows do
      row(:amenties)      {|place| place_amenities_row(place) }
      row(:photos)        {|place| place_photos_row(place)}
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'General' do
      [:user, :place_type, :city, :title].each do |i|
        f.input i
      end
      f.input :description
    end
    f.inputs 'Details' do
      [:num_bedrooms, :num_beds, :num_bathrooms, :max_guests].each do |i|
        f.input i
      end
      f.input :size
    end
    f.inputs 'Location' do
      [:address_1, :address_2, :zip, :lat, :lon].each do |i|
        f.input i
      end
      f.input :directions
    end
    f.inputs 'Pricing' do
      f.input :price_per_month, :input_html => { :maxlength => 10 }
      f.input :currency,  :as => :select,      :collection => Currency.all.collect(&:currency_code)
    end
    f.buttons
  end

  # Publish/Unpublish
  action_item :only => :show do
    if place.published?
      link_to 'Unpublish', unpublish_admin_place_path(place), :method => :put
    else
      link_to 'Publish', publish_admin_place_path(place), :method => :put
    end
  end

  member_action :publish, :method => :put do
    place = Place.find(params[:id])
    published = place.publish!
    redirect_to({:action => :show}, :notice => (published ? "The place was published" : "The place cannot be published"))
  end

  member_action :unpublish, :method => :put do
    place = Place.find(params[:id])
    published = place.unpublish!
    redirect_to({:action => :show}, :notice =>"The place was unpublished")
  end
end
