Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  get "home" => "home#index"

  namespace :api do
    namespace :v1 do
       resource :session do
        get :show
        get :refresh_token
        delete :destroy
      end
      resources :passwords, param: :token
      resources :posts
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
