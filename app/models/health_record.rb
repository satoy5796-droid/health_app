# app/models/health_record.rb
class HealthRecord < ApplicationRecord
  belongs_to :user

  # モデルからビューへストリーミングをブロードキャストできるようにする設定
  include Turbo::Broadcastable

  # バリデーション: condition を整数（1〜5）に制限
  validates :recorded_on, presence: true, uniqueness: { scope: :user_id }
  validates :sleep_time, presence: true, 
                         numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
  validates :condition, presence: true, numericality: { only_integer: true, in: 1..5 }
  
  validate :recorded_on_cannot_be_in_the_future

  # 数値に対応するテキストを返すヘルパーメソッド
  def condition_text
    case condition.to_i
    when 5 then "最高"
    when 4 then "良い"
    when 3 then "普通"
    when 2 then "悪い"
    when 1 then "最悪"
    else "不明"
    end
  end

  def generate_ai_advice
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key])
    
    # AIに5段階スコアの評価軸を明確に伝えるプロンプト
    prompt = <<~EOS
      あなたは健康管理コーチです。以下のデータに基づき、明日をより良く過ごすためのアドバイスを60文字以内で優しく送ってください。
      ・体調(1-5の数値。5が最高、1が最悪): #{condition} (#{condition_text})
      ・睡眠時間: #{sleep_time}時間
      ・朝食: #{breakfast_memo}
      ・昼食: #{lunch_memo}
      ・夕食: #{dinner_memo}
    EOS

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
      }
    )

    if response["choices"]
      advice = response.dig("choices", 0, "message", "content")
      update(ai_advice: advice)
    end
  rescue => e
    # ログに記録した上で、例外を再発生させてActive Jobの retry_on に検知・リトライさせる
    logger.error "OpenAI API Error: #{e.message}"
    raise e
  end

  private

  def recorded_on_cannot_be_in_the_future
    if recorded_on.present? && recorded_on > Date.today
      errors.add(:recorded_on, :cannot_be_in_the_future)
    end
  end
end
