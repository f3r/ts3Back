ActiveAdmin.register Inquiry do
  menu :priority => 5
  actions :index, :show
  
  filter :user 
  filter :place
  filter :created_at

  index do |inquiry|
      id_column
      column :user ,:sortable => :user_id
      column :place  ,:sortable => :place_id
      column :created_at
      default_actions
  end
end
