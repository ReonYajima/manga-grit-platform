class Post < ApplicationRecord
  belongs_to :user
  belongs_to :genre
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  acts_as_taggable_on :tags
  
  # 画像の関連付け（1投稿に1枚のみ）
  has_one_attached :image
  
  # 基本バリデーション
  validates :manga_title, presence: { message: "マンガタイトルは必須です" }
  validates :content, presence: true, length: { minimum: 10 }
  
  # 出典情報のバリデーション（画像がある場合のみ必須）
  validates :manga_author, presence: { message: "著者名は必須です" }, if: :image_attached?
  validates :manga_publisher, presence: { message: "出版社は必須です" }, if: :image_attached?
  validates :manga_volume, presence: { message: "巻数は必須です" }, if: :image_attached?
  validates :manga_page, presence: { message: "ページ数は必須です" }, if: :image_attached?
  
  # 画像のバリデーション
  validate :acceptable_image
  
  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end
  
  def likes_count
    likes.count
  end
  
  # 出典情報の整形表示
  def formatted_citation
    return nil unless image.attached?
    "#{manga_author}『#{manga_title}』第#{manga_volume}巻、#{manga_publisher}、p.#{manga_page}"
  end
  
  private
  
  def image_attached?
    image.attached?
  end

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