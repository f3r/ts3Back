module Admin::CitiesHelper
  def public_city_path(city)
    frontend_url("/#{city.name.parameterize('_')}")
  end
  
  def city_links_column(city)
    html = link_to('Details', admin_city_path(city), :class => 'member_link')
    html << link_to('Edit', edit_admin_city_path(city), :class => 'member_link')
    html << link_to_if(city.active, 'View Public', public_city_path(city), :class => 'member_link', :target => '_blank')
  end
  
end