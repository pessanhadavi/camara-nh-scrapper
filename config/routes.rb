Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'projects#index'
  resources :projects, only: [:show] do
    post :scrape, on: :collection
  end
end
