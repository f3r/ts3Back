HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords, :confirmations ] do
    match "/" => "home#not_found"
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
    # PLACE AVAILABILITIES
    ##############################################################################
    get     "places/:id/availabilities",           :to => "availabilities#list"
    post    "places/:id/availabilities",           :to => "availabilities#create"
    put     "places/:place_id/availabilities/:id", :to => "availabilities#update"
    delete  "places/:place_id/availabilities/:id", :to => "availabilities#destroy"
    ##############################################################################
    # PLACE COMMENTS
    ##############################################################################
    get     "places/:id/comments",           :to => "comments#index"
    post    "places/:id/comments",           :to => "comments#create"
    put     "places/:place_id/comments/:id", :to => "comments#update"
    delete  "places/:place_id/comments/:id", :to => "comments#destroy"
    ##############################################################################
    # PLACES
    ##############################################################################
    get     "places/search",          :to => "places#search"
    post    "places",                 :to => "places#create"
    put     "places/:id",             :to => "places#update"
    get     "places/:id",             :to => "places#show"
    delete  "places/:id",             :to => "places#destroy"
    get     "places/:id/:status",     :to => "places#publish"
    ##############################################################################
    # PLACE TYPES
    ##############################################################################
    get    "place_types",              :to => "place_types#index"
    post   "place_types",              :to => "place_types#create"
    put    "place_types/:id",          :to => "place_types#update"
    delete "place_types/:id",          :to => "place_types#destroy"
    ##############################################################################
    # GEO
    ##############################################################################
    get     "geo/countries",          :to => "geo#get_countries"
    get     "geo/states",             :to => "geo#get_states"
    get     "geo/cities",             :to => "geo#get_cities"
    get     "geo/cities/search",      :to => "geo#city_search"
    get     "geo/cities/:id",         :to => "geo#get_city"
    ##############################################################################
    # USER INFO
    ##############################################################################
    put     "users/:id/change_role",  :to => "users#change_role"
    get     "users/:id/info",         :to => "users#info"
    get     "users/:id/places",       :to => "places#user_places"
    get     "users/:id",              :to => "users#show"
    get     "users",                  :to => "users#show"
    put     "users",                  :to => "users#update"
    ##############################################################################
    # NOTIFICATIONS
    ##############################################################################
    get     "notifications",           :to => "notifications#index"
    get     "notifications/unread",    :to => "notifications#unread"
    get     "notifications/markAsRead",:to => "notifications#mark_as_read"
    ##############################################################################
    # ROUTING ERRORS HACK
    ##############################################################################
    match   '*a',                     :to => 'home#not_found'
  end
end