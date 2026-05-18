# 1. 無料枠のメモリを守るため、同時処理スレッド数を「1」に完全固定
threads 1, 1

# 2. 起動ポートと本番環境の設定
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# 3. クラスターモード（マルチプロセス）を根底から完全に無効化（シングルモードを強制）
# workers機能や、WEB_CONCURRENCYに関わるプラグイン等の記述はここには一切記述しません

# 4. Rails標準の preload_app! もメモリ節約のためシングルモードでは使用しない
# preload_app!
