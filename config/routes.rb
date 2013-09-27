EIPiD::Application.routes.draw do
  root :to => 'pages#index'

  get 'login', to: 'sessions#new', as: 'login'
  match 'logout', to: 'sessions#destroy', as: 'logout', via: [:get, :delete]

  resources :sessions, only: [:new, :create, :destroy]

  namespace :api do
    namespace :v1 do
      resource :cardholder, only: [:show] do
        post :redeem, to: 'cardholders#redeem'
      end
      post 'authorize', to: 'sessions#create'
    end
  end

  resource :venue, only: [:new, :create, :show, :edit, :update] do
    get :signup, to: "venues#new", as: :signup, on: :collection

    get :edit_kiosk, to: "venues#edit_kiosk", as: :edit_kiosk, on: :collection
    put :edit_kiosk, to: "venues#update_kiosk"

    resources :card_levels, only: [:index, :new, :create, :edit, :update] do
      post 'reorder', to: 'card_levels#reorder'

      get 'issue_benefit', to: 'benefits#issue_benefit_form'
      post 'issue_benefit', to: 'benefits#issue_benefit'
    end

    resources :card_themes, except: [:show]

    resources :users

    resources :cardholders, only: [:index] do
      get 'new_batch/:card_level_id', to: "cardholders#batch_new", on: :collection, as: :new_batch
      post 'new_batch/:card_level_id', to: "cardholders#batch_create", on: :collection, as: :create_batch

      get 'bulk_import/:card_level_id', to: "cardholders#bulk_import_form", on: :collection, as: :bulk_import
      post 'bulk_import/:card_level_id', to: "cardholders#bulk_import", on: :collection

      post 'resend_onboarding_sms', as: :resend_onboarding_sms
    end

    resources :cards, only: [:destroy] do
      get :edit_benefits, action: 'edit_benefits'
      put :edit_benefits, action: 'update_benefits'
      get :edit_redeemable_benefits, action: 'edit_redeemable_benefits'
      post :issue_redeemable_benefits, action: 'issue_redeemable_benefits'
      put :activate, action: 'activate_card'
      put :deactivate, action: 'deactivate_card'
      put :change_level, action: 'change_card_level'
      put :review_request, action: 'review_card_request'
    end

    resources :promotions, except: [:index] do
      get :promote, action: 'promote'
      post :promote, action: 'send_promotion'
    end

    resources :benefits, only: [:index, :destroy] do
      post '', action: :index, on: :collection
    end

    resources :partners, except: [:show] do
      resources :temporary_cards, only: [:index] do
        get :new_batch, action: 'batch_new', on: :collection, as: :new_batch
        post :new_batch, action: 'batch_create', on: :collection, as: :create_batch
      end
    end

    resources :temporary_cards, only: [:index, :destroy] do
      get :new_batch, action: 'batch_new', on: :collection, as: :new_batch
      post :new_batch, action: 'batch_create', on: :collection, as: :create_batch
    end
  end

  resource :user, only: [:signup] do
    get :signup
    post :signup, action: :complete_signup
    get :forgot_password
    post :forgot_password, action: :send_password_reset
    match 'reset_password/:reset_token', action: :reset_password_form, on: :collection, via: :get, as: :reset_password
    match 'reset_password/:reset_token', action: :reset_password, on: :collection, via: :put
  end

  resource :cardholder, only: [:reset_pin] do
    get 'reset_pin/:reset_token', action: :reset_pin_form, on: :collection, as: :reset_pin
    put 'reset_pin/:reset_token', action: :reset_pin, on: :collection
  end


  get 'cardholders/:phone_number', to: 'cardholders#check_for_cardholder'
  post 'cardholders/:phone_number/reset_pin', to: 'cardholders#send_pin_reset', as: :send_pin_reset

  get 'cardholders/onboard/:token', to: 'cardholders#onboard', as: :onboard
  put 'cardholders/onboard/:token', to: 'cardholders#complete_onboard'

  namespace :kiosk do
    resource :card_requests, only: [:new, :create]
  end


  constraints VenueSubdomainConstraint do
    get 'request_card', to: 'cards#request_card_form', as: 'request_card'
    post 'request_card', to: 'cards#request_card'

    get 'promotions/:id', to: 'promotions#public_show', as: :public_promotion
    get 'temporary_cards/expired', to: 'temporary_cards#expired', as: :expired_temporary_card
    get 'temporary_cards/claimed', to: 'temporary_cards#claimed', as: :claimed_temporary_card
    get 'temporary_cards/:access_token', to: 'temporary_cards#public_show', as: :public_temporary_card
  end

  ActiveAdmin.routes(self)

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
