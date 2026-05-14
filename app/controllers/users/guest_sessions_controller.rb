class Users::GuestSessionsController < ApplicationController
  # Deviseの認証フィルターから完全に除外する
  skip_before_action :authenticate_user!, raise: false

  def create
    # 💡 ログイン処理の直前にクレンジングを実行し、常に綺麗な状態でお試しを開始させる
    User.cleanup_guest_data
    
    user = User.guest
    sign_in user
    redirect_to root_path, notice: "ゲストとしてログインしました。"
  end
end
