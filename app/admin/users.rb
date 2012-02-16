ActiveAdmin.register User do
  menu :priority => 1
  actions :all, :except => [:destroy]
  
  controller do
    helper 'admin/users'
  end
  
  scope :all, :default => true
  scope :consumer
  scope :agent

  filter :email
  filter :first_name
  filter :last_name
  filter :created_at
  
  index do |place|
    id_column
    column :email
    column :full_name
    column(:role)         {|user| status_tag(user.role) } 
    column :created_at
    column :confirmed_at
    column :last_sign_in_at
    column("Actions")     {|user| user_links_column(user) }
  end
  
  show do |ad|
    rows = default_attribute_table_rows.reject {|a| a =~ /password/}
    attributes_table *rows do
    end
  end
  
  
  # Make Agent
  action_item :only => :show do
    link_to('Make Agent', make_agent_admin_user_path(user), :method => :put, 
      :confirm => 'Are you sure you want to turn the user into an agent?') if user.consumer?
  end
  
  member_action :make_agent, :method => :put do
    user = User.find(params[:id])
    user.update_attribute(:role, 'agent')
    redirect_to({:action => :show}, :notice => "The user is now an agent")
  end
  
end
