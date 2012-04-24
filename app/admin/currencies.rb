ActiveAdmin.register Currency do
  menu :priority => 7
  
   controller do
    helper 'admin/currencies'
    def scoped_collection
      Currency.unscoped
    end
  end
  
  scope :all, :default => true
  scope :active
  scope :inactive

  filter :name
  filter :currency_code
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :symbol
      f.input :currency_code
      f.input :country
      #f.input :currency_position     #some of having symbol on left side ,others have right
      f.input :active
    end
    f.buttons
  end

  
  
  index do
    id_column
    column :name
    column :symbol
    column :currency_code
    column :country
    #column("Postion")     {|currency| status_tag(currency.currency_position == "l"? "Left" : "Right" ,  :style => 'float:left !important') }
    column("Status")      {|currency| status_tag(currency.active ? 'Active' : 'Inactive') }
    column("Actions")     {|currency| currency_links_column(currency) }
  end
  
  # Activate/Deactivate
  action_item :only => :show do
    if currency.active
      link_to 'Deactivate',deactivate_admin_currency_path(currency),  :method => :put
    else
      link_to 'Activate', deactivate_admin_currency_path(currency),:method => :put
    end
  end
  
  member_action :activate, :method => :put do
    currency = Currency.find(params[:id])
    activated = currency.activate!
    redirect_to({:action => :show}, :notice => (activated ? "The Currency was activated" : "The Currency cannot be activated"))
  end
  
  member_action :deactivate, :method => :put do
    currency = Currency.find(params[:id])
    activated = currency.deactivate!
    redirect_to({:action => :show}, :notice =>"The Currency was deactivated")
  end
  
end
