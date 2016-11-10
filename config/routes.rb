Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#show', as: :dashboard
end
