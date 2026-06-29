Rails.application.routes.draw do
  # Customer-facing: ask questions
  resources :assistants, only: [:index, :show] do
    member do
      post :ask
    end
  end

  # Admin-facing: manage the knowledge base
  namespace :admin do
    resources :assistants, only: [:index, :show] do
      member do
        post :ingest
      end
    end
    resources :documents, only: [:destroy]
  end

  root "assistants#index"
end
