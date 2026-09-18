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
    get :media, on: :member
    get :preview, on: :member
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
  post "meet_slots/:id/book", to: "meet_slots#book", as: :book_meet_slot
  resources :wishlists, except: %i[index show] do
    resources :wishlist_items, except: %i[index show]
  end
  post "wishlist_items/:id/contribute", to: "wishlist_items#contribute", as: :contribute_wishlist_item
  get "pay/:purchasable_type/:purchasable_id", to: "payment_claims#new", as: :new_payment_claim
  post "pay/:purchasable_type/:purchasable_id", to: "payment_claims#create", as: :payment_claims_create
  resources :payment_claims, only: :index do
    member do
      post :approve
      post :reject
    end
  end
  resources :creator_posts, except: %i[index show] do
    resource :creator_post_like, only: %i[create destroy]
    resources :creator_post_comments, only: :create
  end

  # Follow lives under the handle so the button can post from the public page
  # without knowing an internal id. Declared before the catch-all show route.
  post   "/:handle/follow", to: "creator_follows#create",  as: :follow_creator
  delete "/:handle/follow", to: "creator_follows#destroy", as: :unfollow_creator

  get "/:handle", to: "profiles#show", as: :profile
end
