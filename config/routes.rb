Rails.application.routes.draw do
  root 'home#index'
  get 'home/index'
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    sessions: "users/sessions",
                                    omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :pictures do
    collection do
      get :bulk_new
      post :bulk_create
      get :point_ranking
      get :win_ranking
      get :my_point_ranking
      get :my_histories
      get :blank_pictures
    end
  end

  get 'conflict/index'
  get 'conflict/elo'
  get 'conflict/img_blank'
  get 'conflict/result'
end
