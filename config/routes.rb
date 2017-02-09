Rails.application.routes.draw do
  resources :routines
  resources :subscriptions, only: %i(new create edit)
  resources :users, only: [ :index, :edit ]

  get 'account', to: 'users#edit', as: :account
  get 'dashboard', to: 'dashboard#show', as: :dashboard

  devise_for :users, :controllers => {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Authenticated Root
  authenticated do
    root to: 'dashboard#show', as: :authenticated_root
  end

  # Unauthenticated Root
  root to: redirect('/temp.html')
end
