Rails.application.routes.draw do
  # resources :orders, only: [:create]
  # Custom routes needed to accept api calls without id in url.
  post "/orders/create" => "orders#create"
  post "/orders/update" => "orders#update"

  # Report
  get "reports/monthly_report" => "reports#monthly_report"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
