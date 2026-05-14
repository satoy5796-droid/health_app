class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :health_records, dependent: :destroy # ユーザーが消えたら記録も消す
  
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
      user.target_sleep_time = 7.5
    end
  end

  # ゲストユーザーの過去の古いデータを一括削除するクレンジング処理
  def self.cleanup_guest_data
    guest_user = find_by(email: 'guest@example.com')
    return unless guest_user

    # ゲストユーザーに紐づく健康記録のうち、今日（操作日）より前のレコードをすべて物理削除
    # 当日のデータだけを残すことで、お試し中の当日の画面表示の崩れを防ぎます
    guest_user.health_records.where('recorded_on < ?', Date.today).destroy_all
  end
end
