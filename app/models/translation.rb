class Translation < ActiveRecord::Base
  scope :template,  where("`translations`.`key` LIKE ?", 'template.%')
  scope :places,  where("`translations`.`key` LIKE ?", 'places.%')
  scope :users,  where("`translations`.`key` LIKE ?", 'users.%')
  scope :workflow,  where("`translations`.`key` LIKE ?", 'workflow.%')
  scope :inquiries,  where("`translations`.`key` LIKE ?", 'inquiries.%')
  scope :messages,  where("`translations`.`key` LIKE ?", 'messages.%')
  scope :pages,  where("`translations`.`key` LIKE ?", 'pages.%')
  scope :city_guides,  where("`translations`.`key` LIKE ?", 'city_guides.%')

  after_commit :delete_cache
  
  private
  def delete_cache
    I18n.cache_store.clear
  end
end