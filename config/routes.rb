Rails.application.routes.draw do
  root to: 'pages#show', id: 'home'
  get 'account', to: 'dashboard#show', as: :account
  get 'dashboard', to: 'dashboard#show', as: :dashboard
  get "/pages/*id" => 'pages#show', as: :page, format: false

  devise_for :users, :controllers => {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :routines
  resources :subscriptions, only: %i(new create edit)
  resources :users, only: :index
end
