HeyPalBackEnd::Application.routes.draw do

  devise_scope :user do
     get "users/sign_up", :to => "registrations#new"
     post "users/sign_in", :to => "sessions#create"
     delete "users/destroy/:id", :to => "registrations#destroy"
  end

end