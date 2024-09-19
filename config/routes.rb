Rails.application.routes.draw do
  resources :users
  resources :users do
    member do
      get 'modal'
    end
  end

  get "api/v1/getAllUsers", to: "users#getAllUsers"

  root "users#show"
end
