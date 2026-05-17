# app/controllers/my_pages_controller.rb
class MyPagesController < ApplicationController
  before_action :authenticate_user!

  def advice_history
    # 1. まずログインユーザーのAIアドバイス生成済みレコードのベースを作る
    base_records = current_user.health_records.where.not(ai_advice: nil).order(recorded_on: :desc)

    # 2. キーワード検索（安全にサニタイズして絞り込む）
    if params[:q].present?
      q = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
      base_records = base_records.where(
        "ai_advice LIKE ? OR breakfast_memo LIKE ? OR lunch_memo LIKE ? OR dinner_memo LIKE ?",
        q, q, q, q
      )
    end

    # 3. 検索・絞り込みが完全に終わったデータオブジェクトを配列化する（ここが重要）
    @all_advice_records = base_records.to_a
    
    # 4. 現在のページ番号を取得
    @current_page = (params[:page] || 1).to_i
  end
end
