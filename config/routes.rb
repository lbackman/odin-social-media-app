Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # creating routes for user posts
  # https://stackoverflow.com/questions/31757006/rails-4-how-do-i-add-an-index-route-for-a-nested-resource-in-order-to-list-al
  
  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :users, except: [:new, :create], concerns: :paginatable do
    resources :friend_requests, only: :index
    resources :posts, except: :index
    member do
      delete :purge_avatar
      get :friends
    end
  end

  resources :posts, only: :index, concerns: :paginatable do
    resources :comments, module: :posts
    resource :like, module: :posts
    resources :likes, only: :index, module: :posts
  end

  resources :comments do
    resource :like, module: :comments
    resources :likes, only: :index, module: :comments
  end

  resources :friend_requests, only: [:create, :update, :destroy]

  # Defines the root path route ("/")
  authenticated :user do
    root to: "posts#index"
  end

  devise_scope :user do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end
end
