class Genre < ApplicationRecord
  # 関連設定
  has_many :posts, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end