class Post < ApplicationRecord
  belongs_to :user
  belongs_to :genre
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  acts_as_taggable_on :tags
  
  # 画像の関連付け（1投稿に1枚のみ）
  has_one_attached :image
  
  validates :manga_title, presence: true
  validates :content, presence: true, length: { minimum: 10 }
  
  # 画像のバリデーション
  validate :acceptable_image
  
  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end
  
  def likes_count
    likes.count
  end
  
  private

  def acceptable_image
    return unless image.attached?

    # サイズ制限（5MB）
    unless image.byte_size <= 5.megabytes
      errors.add(:image, "は5MB以下にしてください")
    end

    # 形式制限
    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "はJPEG, PNG, GIF形式でアップロードしてください")
    end
  end
end