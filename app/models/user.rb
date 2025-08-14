class User < ApplicationRecord
  # Devise設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連設定
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  # バリデーション
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
end