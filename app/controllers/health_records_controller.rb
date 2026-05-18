class HealthRecordsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_health_record, only: %i[ show edit update destroy ]

  def index
    if user_signed_in?
      @range = params[:range] == 'month' ? 1.month : 1.week
      
      # 1. グラフ用データ（全件）
      @health_records = current_user.health_records
                                    .where(recorded_on: @range.ago..Date.today)
                                    .order(:recorded_on)

      # 2. テーブル用データ（最新順で過去の全データから配列化）
      @all_table_records = current_user.health_records.order(recorded_on: :desc).to_a
      @current_page = (params[:page] || 1).to_i
    else
      @health_records = HealthRecord.none
      @all_table_records = []
      @current_page = 1
    end
  end

  def show
  end

  def new
    @health_record = current_user.health_records.build
  end

  def edit
  end

  def create
    existing_record = current_user.health_records.find_by(recorded_on: health_record_params[:recorded_on])
    if existing_record
      @health_record = existing_record
      if @health_record.update(health_record_params)
        GenerateAiAdviceJob.perform_later(@health_record.id)
        redirect_to health_record_url(@health_record), notice: "本日の記録を上書き更新しました。"
      else
        render :new, status: :unprocessable_entity
      end
    else
      @health_record = current_user.health_records.build(health_record_params)
      if @health_record.save
        GenerateAiAdviceJob.perform_later(@health_record.id)
        redirect_to health_record_url(@health_record), notice: "健康記録を保存しました。AIアドバイスを生成中です..."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # ⭕ 決定的な修正ポイント: updateアクション内を、先ほど検証成功した非同期Job呼び出し（perform_later）に100%同期します
  def update
    if @health_record.update(health_record_params)
      # 以前の古い直接呼び出しなどが残っていた場合、ここで500エラーを引き起こしていました
      GenerateAiAdviceJob.perform_later(@health_record.id)
      redirect_to health_record_url(@health_record), notice: "健康記録を更新しました。AIアドバイスを再生成中です..."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_record.destroy
    redirect_to health_records_url, notice: "健康記録を削除しました。"
  end

  private

  def set_health_record
    @health_record = current_user.health_records.find(params[:id])
  end

  # ⭕ ストロングパラメーターの確認: 5段階の数値となった condition を安全に許可
  def health_record_params
    params.require(:health_record).permit(:recorded_on, :sleep_time, :condition, :breakfast_memo, :lunch_memo, :dinner_memo)
  end
end
