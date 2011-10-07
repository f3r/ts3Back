HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords, :confirmations ] do
    post "users/sign_up", :to => "registrations#create"
    post "users/sign_in", :to => "sessions#create"
    delete "users", :to => "registrations#destroy"
    post "users/confirmation", :to => "confirmations#create"
    get "users/confirmation", :to => "confirmations#show"
  end

end