Rails.application.routes.draw do
  devise_for :users, :controllers => {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resource :account, only: [ :show ]
  resources :accounts, only: [ :show ]

  resources :routines
  resources :subscriptions, only: %i(new create edit)

  resources :users, only: [ :index, :edit ]
  resource :user, only: []
  get 'change_password', to: 'users#change_password', as: :change_password
  put 'update_password', to: 'users#update_password', as: :update_password

  #TODO: Convert to resource
  get 'dashboard', to: 'dashboard#show', as: :dashboard

  # Authenticated Root
  authenticated do
    root to: 'dashboard#show', as: :authenticated_root
  end

  # Unauthenticated Root
  root to: redirect('/temp.html')
end
