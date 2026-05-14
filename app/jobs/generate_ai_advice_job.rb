class GenerateAiAdviceJob < ApplicationJob
  queue_as :default

  def perform(health_record_id)
    # 引数として渡されたIDからレコードを取得（見つからない場合は処理を安全に終了）
    health_record = HealthRecord.find_by(id: health_record_id)
    return unless health_record

    # 1. OpenAI APIを呼び出してアドバイスを生成・保存（既存のメソッドを実行）
    health_record.generate_ai_advice

    # 2. 生成完了後、Turbo Streamを使って詳細画面（show）のアドバイス欄だけをリアルタイムに書き換える
    health_record.broadcast_update_to(
      "health_record_#{health_record.id}_advice_channel",
      target: "ai_advice_box_#{health_record.id}",
      partial: "health_records/ai_advice_content",
      locals: { health_record: health_record }
    )
  end
end