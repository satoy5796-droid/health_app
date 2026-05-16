class MyPagesController < ApplicationController
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
    else
      @health_records = base_records
    end
  end
end
