class LoginLog < ApplicationRecord
  belongs_to :user
  
  validates :login_at, presence: true
  
  # スコープ
  scope :recent, -> { order(login_at: :desc) }
  scope :today, -> { where('login_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('login_at >= ?', Time.current.beginning_of_week) }
  
  # 今日初回ログインかチェック
  def self.first_login_today?(user)
    !where(user: user)
      .where('login_at >= ?', Time.current.beginning_of_day)
      .exists?
  end
  
  # ログを記録
  def self.record_login(user)
    create!(
      user: user,
      login_at: Time.current
    )
  end
end