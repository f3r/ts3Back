ActiveAdmin.register Inquiry do
  menu :priority => 5
  actions :index, :show
  filter :created_at

  index do |place|
    id_column
    column("User") do |inquiry|
      if inquiry.user
        link_to(inquiry.user.full_name, admin_user_path(inquiry.user))
      else
        'Guest'
      end
    end
    column :place
    column :created_at
    default_actions
  end
end
