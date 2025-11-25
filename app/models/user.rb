class User < ApplicationRecord
  # Devise設定（validatableを削除）
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  # 関連設定
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # ポイント関連のアソシエーション
  has_many :points, dependent: :destroy
  has_many :daily_missions, dependent: :destroy
  has_many :weekly_missions, dependent: :destroy
  has_many :login_logs, dependent: :destroy

   # 測定関連のアソシエーション
  has_many :grit_scores, dependent: :destroy
  has_many :narrative_scores, dependent: :destroy
  
  # バリデーション
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  
  # メールアドレスを自動生成
  before_validation :generate_email, on: :create
  
  # 共通パスワードの設定（環境変数で管理）
  SEMINAR_PASSWORD = ENV.fetch('SEMINAR_PASSWORD', 'kawano_grit_2024')
  
  # サインアップ時の検証用（仮想属性）
  attr_accessor :seminar_password
  attr_accessor :terms_agreed
  attr_accessor :login
  
  # サインアップ時のみ検証
  validate :check_seminar_password, on: :create
  validate :check_terms_agreement, on: :create
  
  # usernameでログインできるようにする
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["username = :value", { value: login }]).first
    else
      where(conditions).first
    end
  end
  
  # ===== ポイント関連のメソッド（public） =====
  
  # 総ポイントのランキング順位を取得
  def points_rank
    User.where('total_points > ?', total_points).count + 1
  end

  # 今日獲得したポイント
  def points_today
    points.today.sum(:amount)
  end

  # 今週獲得したポイント
  def points_this_week
    points.this_week.sum(:amount)
  end

  # 今日のデイリーミッション
  def todays_missions
    daily_missions.today
  end

  # 今週のウィークリーミッション
  def current_week_missions
    weekly_missions.current_week
  end

  # ログイン連続日数の更新
  def update_login_streak!
    today = Date.current
  
    if last_login_date.nil?
      # 初回ログイン
      update!(login_streak: 1, last_login_date: today)
    elsif last_login_date == today - 1.day
      # 連続ログイン
      increment!(:login_streak)
      update!(last_login_date: today)
    elsif last_login_date < today - 1.day
      # 途切れた
      update!(login_streak: 1, last_login_date: today)
    end
    # last_login_date == today の場合は何もしない（同日の再ログイン）
  end

  # デイリーミッションの初期化（毎日実行）
  def initialize_daily_missions!
    DailyMission.find_or_create_today_missions(self)
  end

  # ウィークリーミッションの初期化（週初めに実行）
  def initialize_weekly_missions!
    WeeklyMission.find_or_create_current_week_missions(self)
  end

  # 最新のグリットスコア
  def latest_grit_score
    grit_scores.order(created_at: :desc).first
  end

  # 最新の物語への移入スコア
  def latest_narrative_score
    narrative_scores.order(created_at: :desc).first
  end

  # 事前測定済みか
  def pre_measurement_completed?
    grit_scores.pre.exists? && narrative_scores.pre.exists?
  end

  # 事後測定済みか
  def post_measurement_completed?
    grit_scores.post.exists? && narrative_scores.post.exists?
  end
  
  # ===== private メソッド =====
  
  private
  
  def generate_email
    self.email = "#{username}@manga-grit-local.jp" if email.blank?
  end
  
  def password_required?
    new_record? || password.present?
  end
  
  def check_seminar_password
    unless seminar_password == SEMINAR_PASSWORD
      errors.add(:seminar_password, "が正しくありません")
    end
  end
  
  def check_terms_agreement
    unless terms_agreed == '1' || terms_agreed == true
      errors.add(:terms_agreed, "利用規約に同意してください")
    end
  end
end