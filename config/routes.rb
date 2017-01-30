Rails.application.routes.draw do
  resources :checkmarks, only: [:index, :destroy]
  resources :exercises
  resources :courses
  resources :users
  resources :test_students
 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  
  # new/update checkmark, JSON only
  post '/checkmarks' => 'checkmarks#mark', defaults: { format: 'json' }, constraints: {format: 'json'}

  # API
  post '/test_students/create' =>  'test_students#create_new_from_form'

  get '/course/:id/checkmarks' => 'courses#get_checkmarks'

end
