HeyPalBackEnd::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords", :confirmations => "confirmations" }
end