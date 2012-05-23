require 'i18n/backend/active_record'
ActiveAdmin.register Translation do
  menu :priority => 8

  filter :locale, :as => :select, :collection => proc { I18n::Backend::ActiveRecord::Translation.available_locales }
  filter :key

  scope :all, :default => true
  scope :template
  scope :places
  scope :users
  scope :workflow
  scope :inquiries
  scope :messages
  scope :pages
  scope :city_guides

  index do
    id_column
    column :locale
    column :key
    column :value, :sortable => false
    column("Status") {|translation| status_tag(!translation.value.blank? ? 'Translated' : 'Not translated') }
    default_actions
  end

  form :partial => "form"

  collection_action :clear_cache, :method => :get do
    I18n.cache_store.clear
    redirect_to({:action => :index}, :notice => "Cache cleared!")
  end

  collection_action :redirect_view, :method => :get do
    key = Translation.where(:locale => params[:locale], :key => params[:key]).first
    redirect_to admin_translation_path(key.id)
  end

  collection_action :redirect_edit, :method => :get do
    key = Translation.where(:locale => params[:locale], :key => params[:key]).first
    redirect_to edit_admin_translation_path(key.id)
  end

  action_item :only => :index do
    link_to('Clear Cache', clear_cache_admin_translations_path)
  end

  show do |ad|
    attributes_table do
      row :locale
      row :key
      row :value
      row :other_languages do
        render 'other_languages', :key => ad.key, :locale => ad.locale
      end
    end
    active_admin_comments
  end

end