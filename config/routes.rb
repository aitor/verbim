Verbim::Application.routes.draw do
  
  resources :words, :only => [:show] do
    post 'search', :on => :collection
  end
  root :to => "home#index"
  
end
