Rails.application.routes.draw do
  root to: 'pages#show', id: 'home'
  get 'dashboard', to: 'dashboard#show', as: :dashboard
  get "/pages/*id" => 'pages#show', as: :page, format: false

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }
end
