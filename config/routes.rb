Rails.application.routes.draw do
  root "chats#index"
  post "ask", to: "chats#ask", as: :ask

  get "up" => "rails/health#show", as: :rails_health_check
end
