ActiveAdmin.register SiteConfig, :as => 'Settings' do
  controller do
    actions :index, :edit, :update

    helper 'admin/settings'
    def index
      redirect_to :action => :edit, :id => 1
    end

    def update
      update! do |format|
        format.html { redirect_to edit_resource_path(resource) }
      end
    end
  end

  form do |f|
    f.inputs "Basic" do
      f.input :site_name
      f.input :site_url
      f.input :mailer_sender
      f.input :support_email
      f.input :mail_bcc
    end
    f.inputs "Credentials" do
      f.input :gae_tracking_code
      f.input :fb_app_id
      f.input :fb_app_secret
      f.input :tw_app_id
      f.input :tw_app_secret
    end
    f.buttons
  end
end