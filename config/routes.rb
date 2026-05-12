Rails.application.routes.draw do
  resources :health_records
  devise_for :users
  
  devise_scope :user do
    get 'users/guest_sign_in', to: 'application#guest_sign_in'
  end

  resources :health_records
  root "health_records#index"
end
