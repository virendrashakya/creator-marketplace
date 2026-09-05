Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"

  get "dashboard", to: "dashboard#show"
  get "creator_settings", to: "creator_settings#edit"
  patch "creator_settings", to: "creator_settings#update"
  resources :creator_blocks, only: %i[index new create destroy]
  resources :collections, except: %i[index show]
  resources :product_links, except: %i[index show]
  get "go/:id", to: "product_links#visit", as: :visit_product_link
  resources :paid_media_posts, except: %i[index show] do
    post :purchase, on: :member
  end
  resources :subscription_plans, except: %i[index show] do
    post :subscribe, on: :member
  end
  resources :paid_media_collections, except: %i[index show]
  resources :contact_reveals, except: %i[index show] do
    post :purchase, on: :member
  end
  resources :meet_offers, except: %i[index show] do
    resources :meet_slots, only: %i[create destroy]
  end
  resources :wishlists, except: %i[index show] do
    resources :wishlist_items, except: %i[index show]
  end
  post "wishlist_items/:id/contribute", to: "wishlist_items#contribute", as: :contribute_wishlist_item
  resources :creator_posts, except: %i[index show] do
    resource :creator_post_like, only: %i[create destroy]
    resources :creator_post_comments, only: :create
  end

  get "/:handle", to: "profiles#show", as: :profile
end
