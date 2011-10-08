HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords, :confirmations ] do
    post "users/sign_up", :to => "registrations#create"
    post "users/sign_in", :to => "sessions#create"
    delete "users", :to => "registrations#destroy"
    post "users/confirmation", :to => "confirmations#create"
    get "users/confirmation", :to => "confirmations#show"
    post "users/password", :to => "passwords#create"
    put "users/password", :to => "passwords#update"
    get "users/:id", :to => "users#show"
    get "categories", :to => "categories#index"
    get "categories/:id", :to => "categories#show"
    post "categories", :to => "categories#create"
    put "categories/:id", :to => "categories#update"
    delete "categories/:id", :to => "categories#destroy"
  end

end