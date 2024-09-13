Rails.application.routes.draw do
  resources :users
  resources :users do
    member do
      get 'modal'
    end
  end

  root "users#show"
end
