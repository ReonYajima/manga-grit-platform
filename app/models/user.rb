class User < ApplicationRecord
  # Devise設定（validatableを削除）
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  # 関連設定
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
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