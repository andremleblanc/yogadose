Rails.application.routes.draw do
  devise_for :users, :controllers => {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resource :account, only: [ :show ]
  resources :accounts, only: [ :show ]

  get '/subscription', to: 'subscriptions#edit'
  post '/subscription', to: 'subscriptions#reactivate', as: 'reactivate_subscription'
  post '/subscriptions', to: 'subscriptions#create'
  patch '/subscription', to: 'subscriptions#update', as: 'update_subscription'
  delete '/subscription', to: 'subscriptions#destroy', as: 'delete_subscription'

  resources :users, only: [ :index, :edit ]
  get 'change_password', to: 'users#change_password', as: :change_password
  put 'update_password', to: 'users#update_password', as: :update_password

  get 'dashboard', to: 'dashboard#show', as: :dashboard

  # Authenticated Root
  authenticated do
    root to: 'dashboard#show', as: :authenticated_root
  end

  # Unauthenticated Root
  root to: redirect('/welcome.html')
end
