require 'pagy/extras/metadata'
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page # 存在しないページにアクセスされたら最終ページを表示する安全策
