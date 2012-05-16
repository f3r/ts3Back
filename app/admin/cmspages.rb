ActiveAdmin.register Cmspage  do
  menu     :priority => 9
  
  config.sort_order = 'id_asc'
  
  scope :all, :default => true
  scope :active
  scope :inactive

  filter :page_title
  
  controller do
    helper 'admin/cmspages'
  end
  
  form do |f|
    f.inputs do
      f.input :page_title
      f.input :page_url , :label => "Page Url", :hint => "Ex: if page url is how , the original url like Siteurl/page/how"
      f.input :route_as , :label => "Route As"
      f.input :description ,:input_html => {:class => 'tinymce'}
      f.input :active
    end
    f.buttons
  end

  
  
  index do
    id_column
    column :page_title
    column :page_url
    column :route_as
    column :description
    column("Status")      {|cmspage| status_tag(cmspage.active ? 'Active' : 'Inactive') }
    column("View")        {|cmspage| cmspage_links_column(cmspage)}
    
  end
  
  # Activate/Deactivate
  action_item :only => :show do
    if cmspage.active
      #link_to 'Deactivate',deactivate_admin_cmspage_path(cmspage),  :method => :put
    else
      #link_to 'Activate', deactivate_admin_cmspage_path(cmspage),:method => :put
    end
  end
  
end
