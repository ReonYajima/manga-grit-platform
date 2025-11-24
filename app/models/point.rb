class Point < ApplicationRecord
  belongs_to :user
  belongs_to :related_post, class_name: 'Post', optional: true
  belongs_to :related_comment, class_name: 'Comment', optional: true
  
  validates :amount, presence: true, numericality: { only_integer: true }
  validates :action_type, presence: true
  
  # ポイント種別の定数
  ACTION_TYPES = {
    post_create: 'post_create',           # 投稿作成: 10pt
    post_with_image: 'post_with_image',   # 画像付き投稿: +5pt
    comment_create: 'comment_create',     # コメント投稿: 3pt
    like_give: 'like_give',               # いいねする: 1pt
    like_receive: 'like_receive',         # いいね受け取り: 1pt
    tag_bonus: 'tag_bonus',               # タグ3つ以上: 2pt
    daily_login: 'daily_login',           # デイリーログイン: 5pt
    daily_post: 'daily_post',             # デイリー1投稿: 10pt
    daily_comments: 'daily_comments',     # デイリー3コメント: 10pt
    daily_likes: 'daily_likes',           # デイリー5いいね: 5pt
    weekly_posts: 'weekly_posts',         # ウィークリー3投稿: 30pt
    weekly_comments: 'weekly_comments',   # ウィークリー10コメント: 20pt
    weekly_likes: 'weekly_likes',         # ウィークリー20いいね: 10pt
    weekly_images: 'weekly_images',       # ウィークリー画像2回: 20pt
    weekly_genres: 'weekly_genres'        # ウィークリー3ジャンル: 30pt
  }.freeze
  
  # スコープ
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }
  scope :by_action_type, ->(type) { where(action_type: type) }
  
  # ポイント付与のクラスメソッド
  def self.award(user:, amount:, action_type:, description: nil, related_post: nil, related_comment: nil)
    transaction do
      point = create!(
        user: user,
        amount: amount,
        action_type: action_type,
        description: description,
        related_post: related_post,
        related_comment: related_comment
      )
      
      # ユーザーの総ポイント更新
      user.increment!(:total_points, amount)
      
      point
    end
  end
  
  # ポイント名の表示用
  def action_type_name
    case action_type
    when 'post_create' then '投稿作成'
    when 'post_with_image' then '画像付き投稿ボーナス'
    when 'comment_create' then 'コメント投稿'
    when 'like_give' then 'いいね'
    when 'like_receive' then 'いいね受け取り'
    when 'tag_bonus' then 'タグボーナス'
    when 'daily_login' then 'デイリーログイン'
    when 'daily_post' then 'デイリー: 1投稿達成'
    when 'daily_comments' then 'デイリー: 3コメント達成'
    when 'daily_likes' then 'デイリー: 5いいね達成'
    when 'weekly_posts' then 'ウィークリー: 3投稿達成'
    when 'weekly_comments' then 'ウィークリー: 10コメント達成'
    when 'weekly_likes' then 'ウィークリー: 20いいね達成'
    when 'weekly_images' then 'ウィークリー: 画像2回達成'
    when 'weekly_genres' then 'ウィークリー: 3ジャンル制覇'
    else action_type
    end
  end
end