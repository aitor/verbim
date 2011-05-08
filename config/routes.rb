Verbim::Application.routes.draw do
  
  resources :words, :only => [:show]
  root :to => "home#index"
  
end
