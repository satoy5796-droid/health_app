class Users::GuestSessionsController < ApplicationController
  # Deviseの認証フィルターから完全に除外する
  skip_before_action :authenticate_user!, raise: false

  def create
    user = User.guest
    sign_in user
    redirect_to root_path, notice: "ゲストとしてログインしました。"
  end
end
