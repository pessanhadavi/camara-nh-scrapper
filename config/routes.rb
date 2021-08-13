Rails.application.routes.draw do
  root to: 'projects#index'
  resources :projects, only: :show do
    post :scrape, on: :collection
  end
end
