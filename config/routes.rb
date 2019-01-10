Rails.application.routes.draw do
  get 'home/index'
  root 'pictures#index'
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    sessions: "users/sessions",
                                    omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :pictures
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
