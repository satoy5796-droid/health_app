class MyPagesController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!

  def advice_history
    # ログインユーザーの健康記録のうち、AIアドバイスが生成済みのものを最新順で取得
    base_records = current_user.health_records.where.not(ai_advice: nil).order(recorded_on: :desc)

    # 検索キーワードがある場合、アドバイス本文や食事メモから絞り込み
    if params[:q].present?
      q = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q])}%"
      @health_records = base_records.where(
        "ai_advice LIKE ? OR breakfast_memo LIKE ? OR lunch_memo LIKE ? OR dinner_memo LIKE ?",
        q, q, q, q
      )
    end
    # 3. ページネーション用に全検索結果を配列化して保持
    @all_advice_records = base_records.to_a
    
    # 4. 現在のページ番号を取得（デフォルトは1ページ目）
    @current_page = (params[:page] || 1).to_i
  end
end
