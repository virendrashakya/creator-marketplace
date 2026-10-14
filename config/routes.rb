Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # The installable app. Rails renders app/views/pwa/*, so both can use
  # helpers and stay in step with the routes.
  get "manifest.webmanifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "offline", to: "pages#offline"
  # Light / dark / system, kept in a cookie.
  patch "theme", to: "themes#update", as: :theme
  resources :push_subscriptions, only: %i[create]
  delete "push_subscriptions", to: "push_subscriptions#destroy"

  root "pages#home"

  # Phone-first accounts. One OTP flow serves three doors: a creator signing
  # up, anyone signing back in, and a fan who only needs an account at the
  # moment they pay.
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_in/email", to: "sessions#email"
  delete "sign_out", to: "sessions#destroy"
  post "otp", to: "otp#create", as: :otp
  get  "otp/verify", to: "otp#edit", as: :verify_otp
  post "otp/verify", to: "otp#update"
  post "otp/resend", to: "otp#resend", as: :resend_otp
  get  "join", to: "otp#join", as: :fan_join

  # Creator onboarding, four steps.
  get   "start", to: "onboarding#phone", as: :start
  get   "start/profile", to: "onboarding#profile", as: :onboarding_profile
  patch "start/profile", to: "onboarding#update_profile"
  get   "start/upi", to: "onboarding#upi", as: :onboarding_upi
  patch "start/upi", to: "onboarding#update_upi"
  get   "start/live", to: "onboarding#live", as: :onboarding_live
  # The old email sign-up still works for links already out in the world.
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  # ---- Studio: the creator's side ----
  get "dashboard", to: "dashboard#show"
  get "creator_settings", to: "creator_settings#edit"
  patch "creator_settings", to: "creator_settings#update"
  resources :creator_blocks, only: %i[index new create destroy]
  resources :collections, except: %i[index show]
  resources :product_links, except: %i[show]
  get "go/:id", to: "product_links#visit", as: :visit_product_link
  resources :paid_media_posts, except: %i[index show] do
    post :purchase, on: :member
    get :media, on: :member
    get :preview, on: :member
  end
  resources :subscription_plans, except: %i[index show] do
    post :subscribe, on: :member
  end
  resources :paid_media_collections, except: %i[show] do
    member do
      post :items
      patch :reorder
      delete "items/:post_id", action: :remove_item, as: :remove_item
    end
  end
  resources :link_lists, path: "lists", except: %i[show] do
    member do
      patch :reorder
      get :qr
    end
    resources :items, controller: "link_list_items", only: %i[create update destroy]
  end
  get "l/:id", to: "link_list_items#visit", as: :visit_link_list_item
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

  # ---- Paying ----
  get "pay/:purchasable_type/:purchasable_id", to: "payment_claims#new", as: :new_payment_claim
  post "pay/:purchasable_type/:purchasable_id", to: "payment_claims#create", as: :payment_claims_create
  resources :payment_claims, only: %i[index show] do
    member do
      post :approve
      post :reject
      # "Ask ₹100": a short-paid claim opens a DM asking for the rest.
      post :nudge
    end
  end
  # A fan's own library: everything they have unlocked, readable offline.
  get "unlocks", to: "unlocks#index", as: :unlocks

  resources :creator_posts, except: %i[show] do
    resource :creator_post_like, only: %i[create destroy]
    resources :creator_post_comments, only: :create
  end

  # The websocket. Live chat and direct messages both ride it, and the
  # connection authenticates from the same session cookie as every request,
  # so a socket is never more trusted than a page load.
  mount ActionCable.server => "/cable"

  # Scheduled lives. The room is public so a non-member can open the link
  # from a story; the stream inside is gated on an active subscription.
  resources :live_sessions, path: "lives", except: :index do
    member do
      # The creator's control room, as distinct from the viewer's page.
      get :studio
      post :start
      post :finish
    end
    resources :live_messages, only: %i[create index], path: "messages"
  end

  # One calendar for booked meets and scheduled lives: the Book screen.
  get "schedule", to: "schedule#show"

  # Direct messages, which are a different feature from live chat: private to
  # two people and kept after the broadcast ends.
  resources :conversations, only: %i[index show] do
    resources :direct_messages, only: %i[create index], path: "messages"
  end

  # ---- The public storefront, all under the handle ----
  # Declared last so every fixed path above wins. Follow and message post
  # from the public page without knowing an internal id.
  post   "/:handle/message", to: "conversations#create", as: :message_creator
  post   "/:handle/follow", to: "creator_follows#create",  as: :follow_creator
  delete "/:handle/follow", to: "creator_follows#destroy", as: :unfollow_creator

  get "/:handle/c/:id", to: "paid_media_collections#show", as: :public_collection
  get "/:handle/c/:id/view", to: "paid_media_collections#viewer", as: :collection_viewer
  get "/:handle/d/:id", to: "paid_media_posts#show", as: :public_drop
  get "/:handle/p/:id", to: "creator_posts#show", as: :public_post
  get "/:handle/close-friends", to: "profiles#close_friends", as: :close_friends
  get "/:handle/spoil-me", to: "profiles#spoil_me", as: :spoil_me
  get "/:handle", to: "profiles#show", as: :profile
  get "/:handle/:slug", to: "link_lists#public", as: :public_link_list
end
