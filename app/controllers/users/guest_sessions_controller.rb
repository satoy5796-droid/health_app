class Users::GuestSessionsController < ApplicationController
  # Deviseの認証フィルターから完全に除外する
  skip_before_action :authenticate_user!, raise: false

  def create
    # 1. ゲストユーザーを取得または作成
    user = User.find_or_create_by!(email: 'guest@example.com') do |u|
      u.password = SecureRandom.urlsafe_base64
      u.name = 'ゲストユーザー'
    end

    # 2. 【クレンジング機能】データ肥大化を防ぐため、このゲストの過去の古いデータを一回全消去
    user.health_records.destroy_all

    # 3. 【サンプルデータの自動生成】直近7日間のリアルなデータをDBに直接インサート
    # AIアドバイスもあらかじめ本物らしい文章をセットしておくことで、OpenAIのAPI通信や料金を消費せずに一瞬でモックデータを構築します
    sample_data = [
      { date: 6.days.ago.to_date, sleep: 5.5, cond: 2, b: "トースト、コーヒー", l: "カップ麺", d: "居酒屋（唐揚げ、ビール）", advice: "睡眠時間が短く、塩分や脂質の多い食事が続いて体調に影響が出ているようです。今夜は消化に良い温かいものを食べて、早めに就寝しましょう。" },
      { date: 5.days.ago.to_date, sleep: 7.0, cond: 3, b: "バナナ、ヨーグルト", l: "立ち食いそば", d: "サバの塩焼き定食", advice: "昨夜しっかり眠れたことで体調が「普通」まで回復しましたね！食事のバランスも改善されています。この調子で水分補給を意識してください。" },
      { date: 4.days.ago.to_date, sleep: 6.5, cond: 3, b: "シリアル、牛乳", l: "コンビニおにぎり、サラダ", d: "パスタ、スープ", advice: "安定したリズムがキープできています。昼食にサラダを取り入れたのは素晴らしい選択です！午後の眠気対策に、軽いストレッチがおすすめです。" },
      { date: 3.days.ago.to_date, sleep: 4.5, cond: 1, b: "なし（寝坊）", l: "ハンバーガーセット", d: "深夜にラーメン", advice: "睡眠4.5時間はかなりお体が辛いサインです。朝食を抜くと代謝も下がってしまいます。今日は無理をせず、タスクを早めに切り上げて休養を最優先に！" },
      { date: 2.days.ago.to_date, sleep: 8.0, cond: 4, b: "雑炊、緑茶", l: "うどん", d: "生姜焼き、お味噌汁", advice: "8時間の大満足の睡眠、素晴らしいです！体調も「良い」まで一気に上がりましたね。胃に優しい食事を意識したおかげで消化器も喜んでいます。" },
      { date: 1.day.ago.to_date,  sleep: 7.5, cond: 5, b: "和食定食（ご飯、納豆、卵）", l: "チキン南蛮弁当", d: "自炊（鍋料理）", advice: "体調スコア5（最高）おめでとうございます！質の良い睡眠と栄養満点の朝食が最高のスタートを作りました。夜の鍋料理も温まって完璧な選択です。" },
      { date: Date.today,          sleep: 7.0, cond: 4, b: "サンドイッチ、豆乳", l: "パスタランチ", d: "焼き魚、ほうれん草お浸し", advice: "本日も安定して良い調子を維持できていますね。一週間の振り返りとして、今夜はゆっくりお風呂に浸かって肩の力を抜いて過ごしてください。" }
    ]

    sample_data.each do |data|
      user.health_records.create!(
        recorded_on: data[:date],
        sleep_time: data[:sleep],
        condition: data[:cond],
        breakfast_memo: data[:b],
        lunch_memo: data[:l],
        dinner_memo: data[:d],
        ai_advice: data[:advice] # ログイン直後からアドバイスが表示されるよう最初から注入
      )
    end

    # 4. サインインさせてダッシュボードへリダイレクト
    sign_in user
    redirect_to health_records_path, notice: 'ゲストユーザーとしてログインしました。デモデータが生成されました。'
  end
end
