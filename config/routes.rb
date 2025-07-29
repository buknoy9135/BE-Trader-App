Rails.application.routes.draw do
  get "home/index"
  namespace :admin do
    get "errors/not_found"
    get "dashboard", to: "dashboard#index", as: :dashboard

    resources :transactions, only: [ :index, :show ]
    resources :portfolios, only: [ :index, :show ]

    resources :users do
      member do
        patch :confirm
        patch :approve
        patch :reject
        patch :ban
        patch :unban
        post :resend_confirmation
      end
    end
  end

  namespace :trader do
    get "dashboard", to: "dashboard#index", as: :dashboard

    resources :stocks, only: [ :index, :show ]
    resources :users do
      resources :funds
    end
    resources :transactions

    get "portfolio", to: "portfolio#index", as: :portfolio

    get "stock_price/:symbol", to: "stocks#price", as: :stock_price
  end


  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "home#index"

  # for error handling of routes
  match "*path", to: "admin/errors#not_found", via: :all
end
