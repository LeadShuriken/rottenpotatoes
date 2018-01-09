Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :movies
  root :to => redirect('/movies')
  get '/movies/:id/similar_movies' => 'movies#search_similar_movies', as: 'search_similar_movies'
end
