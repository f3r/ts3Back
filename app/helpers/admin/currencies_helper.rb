module Admin::CurrenciesHelper
  def public_currency_path(currency)
    frontend_url("/#{currency.name.parameterize('_')}")
  end
  
  def currency_links_column(currency)
    html = link_to('Details', admin_currency_path(currency), :class => 'member_link')
    html << link_to('Edit', edit_admin_currency_path(currency), :class => 'member_link')
    #html << link_to_if(currency.active, 'View Public', public_currency_path(currency), :class => 'member_link', :target => '_blank')
  end
  
end