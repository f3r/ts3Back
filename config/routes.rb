HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords, :confirmations ] do
    ##############################################################################
    # ACCOUNTS & REGISTRATION
    ##############################################################################
    post   "users/sign_up",           :to => "registrations#create"
    get    "users/email_exists",      :to => "registrations#email_exists"
    post   "users/sign_in",           :to => "sessions#create"
    delete "users",                   :to => "registrations#destroy"
    post   "users/confirmation",      :to => "confirmations#create"
    get    "users/confirmation",      :to => "confirmations#show"
    post   "users/password",          :to => "passwords#create"
    put    "users/password",          :to => "passwords#update"
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
    # PROVIDERS
    ##############################################################################
    post   "users/:provider/sign_in", :to => "sessions#oauth_create"
    post   "users/:provider/sign_up", :to => "registrations#create"
    get    "users/authentications",   :to => "authentications#list"
    delete "users/authentications/:authentication_id",  :to => "authentications#delete"
    get    "users/facebook/info",  :to => "authentications#get_facebook_info"
    ##############################################################################
    # ITEMS
    ##############################################################################
    get    "items/image_search/",     :to => "items#image_search"
  end
end