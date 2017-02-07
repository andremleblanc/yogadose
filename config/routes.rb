Rails.application.routes.draw do
  resources :routines
  resources :subscriptions, only: %i(new create edit)
  resources :users, only: :index

  get 'account', to: 'dashboard#show', as: :account
  get 'dashboard', to: 'dashboard#show', as: :dashboard

  # Static Pages Routes
  get "/pages/*id" => 'pages#show', as: :page, format: false

  devise_for :users, :controllers => {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Authenticated Root
  authenticated do
    root to: 'dashboard#show', as: :authenticated_root
  end

  # Unauthenticated Root
  root to: 'pages#show', id: 'home'
end
