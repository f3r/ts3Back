class CreateSiteConfigEntryForSite < ActiveRecord::Migration
  def up
    SiteConfig.create(:id => 1)
  end

  def down
    SiteConfig.find(1).destroy
  end
end
