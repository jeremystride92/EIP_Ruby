EIPiD::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root :to => 'pages#index'

  get 'login', to: 'sessions#new', as: 'login'
  match 'logout', to: 'sessions#destroy', as: 'logout', via: [:get, :delete]

  resources :sessions, only: [:new, :create, :destroy]

  namespace :api do
    namespace :v1 do
      resource :cardholder, only: [:show] do
        post :checkin, to: 'cardholders#checkin'
      end
      post 'authorize', to: 'sessions#create'
    end
  end

  resource :venue, only: [:new, :create, :show, :edit, :update] do
    get :signup, to: "venues#new", as: :signup, on: :collection

    resources :card_levels
    resources :users

    resources :cardholders, only: [:index] do
      get 'new_batch/:card_level_id', to: "cardholders#batch_new", on: :collection, as: :new_batch
      post 'new_batch/:card_level_id', to: "cardholders#batch_create", on: :collection, as: :create_batch
    end

    resources :cards, only: [] do
      get :edit_benefits, action: 'edit_benefits'
      put :edit_benefits, action: 'update_benefits'
      get :edit_guest_passes, action: 'edit_guest_passes'
      post :issue_guest_passes, action: 'issue_guest_passes'
      put :activate, action: 'activate_card'
      put :deactivate, action: 'deactivate_card'
      put :change_level, action: 'change_card_level'
      put :review_request, action: 'review_card_request'
    end

    resources :promotions, except: [:index] do
      get :promote, action: 'promote'
      post :promote, action: 'send_promotion'
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

  get 'cardholders/:phone_number', to: 'cardholders#check_for_cardholder'

  get 'cardholders/onboard/:token', to: 'cardholders#onboard', as: :onboard
  put 'cardholders/onboard/:token', to: 'cardholders#complete_onboard'

  constraints VenueSubdomainConstraint do
    get 'request_card', to: 'cards#request_card_form', as: 'request_card'
    post 'request_card', to: 'cards#request_card'

    get 'promotions/:id', to: 'promotions#public_show', as: :public_promotion
  end

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
