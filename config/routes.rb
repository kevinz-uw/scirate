Scirate::Application.routes.draw do
  root :to => 'home#index'

  match '/auth/:provider/callback' => 'sessions#create'
  match '/signout' => 'sessions#destroy', :as => :signout

  match '/about' => 'static_pages#about'
  match '/privacy' => 'static_pages#privacy_policy'
  match '/faq' => 'static_pages#faq'

  resources :articles
  resources :interests
  resources :ratings
  resource :user
  resources :analytics
  resource :report_bug
end
