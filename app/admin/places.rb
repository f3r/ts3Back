ActiveAdmin.register Place do
  controller do
    helper :places
  end
  
  scope :all, :default => true
  scope :published
  scope :unpublished
  
  filter :title
  filter :user
  filter :city
  
  index do |place|
    id_column
    column :title
    column :user
    column :city
    column :created_at
    column :updated_at
    column("Status")      {|place| status_tag(place.published ? 'Published' : 'Unpublished') }
    column("Actions")     {|place| place_links_column(place) }
  end
  
  show do |ad|
    rows = default_attribute_table_rows.reject {|a| a =~ /photos|amenities|review/}
    attributes_table *rows do
      row(:amenties)      {|place| place_amenities_row(place) }
      row(:photos)        {|place| place_photos_row(place)}
    end
  end
end
