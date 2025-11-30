Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # CRM Namespace (Business Users)
  namespace :crm do
    root to: "dashboard#index"
    resources :dashboard, only: [ :index ]
    get "company/edit", to: "company#edit", as: :edit_company
  end

  # Screener Namespace (End Consumers)
  namespace :screener do
    root to: "home#index"
  end

  # Admin Namespace (Administrators)
  namespace :admin do
    root to: "dashboard#index"
    resources :dashboard, only: [ :index ]
    resources :users, only: [ :index, :show ]
  end

  # Root route redirects to Screener (or could be a landing page)
  root "screener/home#index"
end
