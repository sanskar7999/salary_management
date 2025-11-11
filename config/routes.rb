Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :employees, defaults: { format: :json } do
    # GET collection routes for salary metrics
    collection do
      get :salary_metrics_by_country
      get :salary_metrics_by_job_title
    end

    # POST member route for deductions
    post :deductions, on: :member
  end
end
