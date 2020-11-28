Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "works#root"
  post "/logout", to: "users#logout", as: "logout"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  resources :users, only: [:index, :show]

  get "/auth/github", as: "github_login"
  get "/auth/google_oauth2", as: "google_login"
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"
end
