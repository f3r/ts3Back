HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords, :confirmations ] do
    ##############################################################################
    # ACCOUNTS & REGISTRATION
    ##############################################################################
    post   "users/sign_up",           :to => "registrations#create"
    get    "users/check_email",       :to => "registrations#check_email"
    post   "users/sign_in",           :to => "sessions#create"
    delete "users",                   :to => "registrations#destroy"
    post   "users/confirmation",      :to => "confirmations#create"
    get    "users/confirmation",      :to => "confirmations#show"
    post   "users/password",          :to => "passwords#create"
    put    "users/password",          :to => "passwords#update"
    ##############################################################################
    # PROVIDERS
    ##############################################################################
    post   "users/oauth/sign_in",     :to => "sessions#oauth_create"
    post   "users/oauth/sign_up",     :to => "registrations#create"
    get    "authentications",         :to => "authentications#list"
    post   "authentications",         :to => "authentications#create"
    get    "users/facebook/info",     :to => "authentications#get_facebook_oauth_info"
    delete "authentications/:authentication_id",  :to => "authentications#delete"
    ##############################################################################
    # ADDRESSES
    ##############################################################################
    get    "users/addresses",         :to => "addresses#index"
    post   "users/addresses",         :to => "addresses#create"
    put    "users/addresses/:id",     :to => "addresses#update"
    delete "users/addresses/:id",     :to => "addresses#destroy"
    ##############################################################################
    # CATEGORIES
    ##############################################################################
    get    "categories",              :to => "categories#index"
    get    "categories/list",         :to => "categories#list"
    get    "categories/:id",          :to => "categories#show"
    post   "categories",              :to => "categories#create"
    put    "categories/:id",          :to => "categories#update"
    delete "categories/:id",          :to => "categories#destroy"
    ##############################################################################
    # ITEMS
    ##############################################################################
    get    "items/image_search",      :to => "items#image_search"
    ##############################################################################
    # USER INFO
    ##############################################################################
    get    "users/:id/info",          :to => "users#info"
    get    "users/:id",               :to => "users#show"
    get    "users",                   :to => "users#show"
    put    "users",                   :to => "users#update"
  end
end