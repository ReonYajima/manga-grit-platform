class Post < ApplicationRecord
  belongs_to :user
  belongs_to :genre
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  acts_as_taggable_on :tags
  
  validates :manga_title, presence: true
  validates :content, presence: true, length: { minimum: 10 }
  
  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end
  
  def likes_count
    likes.count
  end
end