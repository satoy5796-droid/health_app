class HealthRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_health_record, only: %i[ show edit update destroy ]

  # GET /health_records or /health_records.json
  def index
    # 期間の判定（デフォルトは1週間）
    @range = params[:range] == 'month' ? 1.month : 1.week
    
    # 自分のデータを取得
    @health_records = current_user.health_records
                                  .where(recorded_on: @range.ago..Date.today)
                                  .order(:recorded_on)
  end

  # GET /health_records/1 or /health_records/1.json
  def show
  end

  # GET /health_records/new
  def new
    @health_record = HealthRecord.new
  end

  # GET /health_records/1/edit
  def edit
  end

  # POST /health_records or /health_records.json
  def create
    # ① 入力された日付の既存レコードがあるか探す
    existing_record = current_user.health_records.find_by(recorded_on: health_record_params[:recorded_on])

    if existing_record
      # 【修正箇所】既存レコードがある場合、変数名を @health_record にする
      @health_record = existing_record
      
      if @health_record.update(health_record_params)
        @health_record.generate_ai_advice
        redirect_to health_record_url(@health_record), notice: "本日の記録を上書き更新しました。"
      else
        # ここで _form.html.erb に @health_record が渡されます
        render :new, status: :unprocessable_entity
      end
    else
      # ② 新規作成の場合
      @health_record = current_user.health_records.build(health_record_params)
      
      if @health_record.save
        @health_record.generate_ai_advice
        redirect_to health_record_url(@health_record), notice: "健康記録を保存し、AIアドバイスを生成しました。"
      else
        render :new, status: :unprocessable_entity
      end
    end
  end



  # PATCH/PUT /health_records/1 or /health_records/1.json
  def update
    respond_to do |format|
      if @health_record.update(health_record_params)
        @health_record.generate_ai_advice
        format.html { redirect_to @health_record, notice: "健康記録を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @health_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @health_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /health_records/1 or /health_records/1.json
  def destroy
    @health_record.destroy!

    respond_to do |format|
      format.html { redirect_to health_records_path, notice: "健康記録を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_health_record
      @health_record = current_user.health_records.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def health_record_params
      params.require(:health_record).permit(:user_id, :recorded_on, :condition, :sleep_time, :breakfast_memo, :lunch_memo, :dinner_memo, :ai_advice)
    end
end
