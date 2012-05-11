class CreateSiteConfigs < ActiveRecord::Migration
  def change
    create_table :site_configs do |t|
      t.string :site_name, :site_url, :mailer_sender, :support_email
      t.string :gae_tracking_code
      t.string :fb_app_id, :fb_app_secret, :tw_app_id, :tw_app_secret
      t.string :mail_bcc
      t.timestamps
    end
  end
end
