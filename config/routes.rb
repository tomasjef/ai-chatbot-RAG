Rails.application.routes.draw do
  # Customer-facing: ask the single HALO assistant.
  root "assistants#show"
  post "ask", to: "assistants#ask", as: :ask

  resources :documents, only: [ :show ]

  # Admin-facing: manage the HALO knowledge base.
  namespace :admin do
    root "assistants#show"
    post "ingest", to: "assistants#ingest", as: :ingest

    resources :documents, only: [ :destroy ]
  end
end
