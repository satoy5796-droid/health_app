Rails.application.routes.draw do
  # 開発環境の時だけ、メールボックス画面のURLを有効化する
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users

  # ゲストログイン専用の独立したルーティング
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/guest_sessions#create', as: :users_guest_sign_in
  end

  resources :health_records
  root "health_records#index"
end
