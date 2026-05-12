class HealthRecord < ApplicationRecord
  belongs_to :user
  validates :recorded_on, presence: true, uniqueness: { scope: :user_id }

  def generate_ai_advice
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key])
    
    prompt = <<~EOS
      あなたは健康管理コーチです。以下のデータに基づき、明日をより良く過ごすためのアドバイスを60文字以内で優しく送ってください。
      ・体調(1-5): #{condition}
      ・睡眠時間: #{sleep_time}時間
      ・朝食: #{breakfast_memo}
      ・昼食: #{lunch_memo}
      ・夕食: #{dinner_memo}
    EOS

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo", # または "gpt-4"
        messages: [{ role: "user", content: prompt }],
      }
    )

    if response["choices"]
      advice = response.dig("choices", 0, "message", "content")
      update(ai_advice: advice)
    end
  rescue => e
    # エラーが起きてもログに記録するだけで、アプリは止めない
    logger.error "AI Advice Generation Failed: #{e.message}"
    update(ai_advice: "現在、アドバイスを生成できません。時間を置いて確認してください。")
  end
end
