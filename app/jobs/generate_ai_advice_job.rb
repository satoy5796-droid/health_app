class GenerateAiAdviceJob < ApplicationJob
  queue_as :default

  # 1. 429 Too Many Requests (レートリミット) が発生した場合、20秒空けて最大3回リトライする
  retry_on Faraday::TooManyRequestsError, wait: 20.seconds, attempts: 3 do |job, error|
    Rails.logger.error "OpenAI Rate Limit Exceeded permanently: #{error.message}"
    set_error_advice(job.arguments.first, "現在、AIアドバイスの利用制限に達しています。少し時間を空けてから、編集ボタンより再生成をお試しください。")
  end

  # 2. タイムアウトや接続エラーなどの一時的エラーが発生した場合、5秒空けて最大3回リトライする
  retry_on Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError, StandardError, wait: 5.seconds, attempts: 3 do |job, error|
    Rails.logger.error "AI Advice Generation Formally Failed after retries: #{error.message}"
    set_error_advice(job.arguments.first, "現在AIが混雑しています。時間をおいて、上の編集ボタンから再生成をお試しください。")
  end

  def perform(health_record_id)
    health_record = HealthRecord.find_by(id: health_record_id)
    return unless health_record

    # OpenAI API通信を実行（例外はすべて上記 retry_on が検知・リトライします）
    health_record.generate_ai_advice 

    # 正常に完了した場合は、フロントのアドバイス内容をリアルタイム自動置換
    health_record.broadcast_update_to(
      "health_record_#{health_record.id}_advice_channel",
      target: "ai_advice_box_#{health_record.id}",
      partial: "health_records/ai_advice_content",
      locals: { health_record: health_record }
    )
  end

  private

  # リトライ上限を超えて完全に失敗した際、ユーザー画面を「分析中...」のまま放置せずエラーメッセージに切り替えるメソッド
  def set_error_advice(health_record_id, message)
    health_record = HealthRecord.find_by(id: health_record_id)
    return unless health_record

    health_record.update(ai_advice: message)
    health_record.broadcast_update_to(
      "health_record_#{health_record.id}_advice_channel",
      target: "ai_advice_box_#{health_record.id}",
      partial: "health_records/ai_advice_content",
      locals: { health_record: health_record }
    )
  end
end
