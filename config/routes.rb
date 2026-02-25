Rails.application.routes.draw do
  # Session routes
  get  '/login',  to: 'sessions#new',     as: :login
  post '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Registration
  get  '/signup', to: 'users#new',    as: :signup
  post '/signup', to: 'users#create'

  # Profile
  resource :profile, controller: 'users', only: %i[edit update]

  # Vehicles with nested resources
  resources :vehicles do
    resources :fuel_logs do
      collection do
        get :export
        post :import
      end
    end
    resources :service_logs do
      collection do
        get :export
        post :import
      end
    end
    resources :reminders do
      member do
        patch :complete
      end
    end
    resource :report, only: [:show]
  end

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # PWA
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  root 'home#index'
end
