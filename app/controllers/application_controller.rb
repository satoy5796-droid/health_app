class ApplicationController < ActionController::Base
  # ゲストログイン用のアクション
  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to root_path, notice: "ゲストとしてログインしました。"
  end
end
