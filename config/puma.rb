# 1. 無料枠のメモリを守るため、最大・最小スレッド数を「1」に完全制限
threads 1, 1

# 2. 起動ポートと本番環境の設定
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }