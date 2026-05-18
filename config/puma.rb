# 1. 無料枠のメモリを守るため、最大・最小スレッド数を「1」に完全制限
threads 1, 1

# 2. 起動ポートと本番環境の設定
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# 3. ⭕ 決定版の修正: Pumaの起動と同時に、同じプロセス内でSolid Queueを常駐駆動させる公式プラグインを有効化
# これにより、メモリ消費量を限界まで抑えたまま、非同期ジョブ（AI生成）の受け皿が本番環境に出現します
plugin :solid_queue
