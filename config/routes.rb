Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#show', as: :dashboard
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'
end
