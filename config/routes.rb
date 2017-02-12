Rails.application.routes.draw do
  devise_for :users, :controllers => {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :routines
  resources :subscriptions, only: %i(new create edit)
  resources :users, only: [ :index, :edit ]

  get 'account', to: 'users#edit', as: :account
  get 'dashboard', to: 'dashboard#show', as: :dashboard

  # Authenticated Root
  authenticated do
    root to: 'dashboard#show', as: :authenticated_root
  end

  # Unauthenticated Root
  root to: redirect('/temp.html')
end
