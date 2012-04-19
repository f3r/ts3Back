ActiveAdmin.register City do
  menu :priority => 6
  
  controller do
    helper 'admin/cities'
  end
  
  scope :all, :default => true
  scope :active
  scope :inactive

  filter :name
  filter :state
  filter :country
  filter :country_code, :as => :select, :collection => proc { City.select(["country_code as name"]).find(:all, :group => "country_code") }

  form do |f|
    f.inputs do
      f.input :name
      f.input :lat
      f.input :lon
      f.input :state
      f.input :country
      f.input :country_code
      f.input :active
    end
    f.buttons
  end

  index do
    id_column
    column :name
    column :state
    column :country
    column :country_code
    column("Status")      {|city| status_tag(city.active ? 'Active' : 'Inactive') }
    column("Actions")     {|city| city_links_column(city) }
  end

  # Activate/Deactivate
  action_item :only => :show do
    if city.active
      link_to 'Deactivate', deactivate_admin_city_path(city), :method => :put
    else
      link_to 'Activate', activate_admin_city_path(city), :method => :put
    end
  end
  
  member_action :activate, :method => :put do
    city = City.find(params[:id])
    activated = city.activate!
    redirect_to({:action => :show}, :notice => (activated ? "The city was activated" : "The city cannot be activated"))
  end
  
  member_action :deactivate, :method => :put do
    city = City.find(params[:id])
    activated = city.deactivate!
    redirect_to({:action => :show}, :notice =>"The city was deactivated")
  end
end
