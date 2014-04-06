FacebookSearch::Application.routes.draw do
  get "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure", to: redirect('/')
  delete "/signout" => "sessions#destroy", as: :signout
  root "welcome#new"
end
