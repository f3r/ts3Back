HeyPalBackEnd::Application.routes.draw do

  devise_for :users, :skip => [ :registrations, :sessions, :passwords ] do
    post "users/sign_up", :to => "registrations#create"
    post "users/sign_in", :to => "sessions#create"
    delete "users", :to => "registrations#destroy"
  end

end