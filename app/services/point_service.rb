class PointService
  # 投稿作成時のポイント付与
  def self.award_for_post_create(post)
    amount = 10 # 基本ポイント
    
    # 画像付きなら+5pt
    if post.image.attached?
      amount += 5
      Point.award(
        user: post.user,
        amount: 5,
        action_type: 'post_with_image',
        description: '画像付き投稿ボーナス',
        related_post: post
      )
    end
    
    # 投稿作成ポイント
    Point.award(
      user: post.user,
      amount: 10,
      action_type: 'post_create',
      description: '投稿作成',
      related_post: post
    )
    
    # タグ3つ以上で+2pt
    if post.tag_list.count >= 3
      Point.award(
        user: post.user,
        amount: 2,
        action_type: 'tag_bonus',
        description: 'タグ3つ以上ボーナス',
        related_post: post
      )
    end
    
    # デイリーミッション「1投稿する」の進捗更新
    update_daily_mission(post.user, 'post')
    
    # ウィークリーミッション「3投稿する」の進捗更新
    update_weekly_mission(post.user, 'posts')
    
    # 画像付きならウィークリーミッション「画像2回」も更新
    if post.image.attached?
      update_weekly_mission(post.user, 'images')
    end
    
    # ジャンル数をカウント
    update_genre_mission(post.user)
  end
  
  # コメント作成時のポイント付与
  def self.award_for_comment_create(comment)
    # 自分の投稿へのコメントは対象外
    return if comment.post.user_id == comment.user_id
    
    # コメント投稿ポイント
    Point.award(
      user: comment.user,
      amount: 3,
      action_type: 'comment_create',
      description: 'コメント投稿',
      related_comment: comment,
      related_post: comment.post
    )
    
    # デイリーミッション「3コメントする」の進捗更新
    update_daily_mission(comment.user, 'comments')
    
    # ウィークリーミッション「10コメントする」の進捗更新
    update_weekly_mission(comment.user, 'comments')
  end
  
  # いいね作成時のポイント付与
  def self.award_for_like_create(like)
    # 自分の投稿へのいいねは対象外
    return if like.post.user_id == like.user_id
    
    # いいねした人にポイント
    Point.award(
      user: like.user,
      amount: 1,
      action_type: 'like_give',
      description: 'いいね',
      related_post: like.post
    )
    
    # 投稿者にポイント
    Point.award(
      user: like.post.user,
      amount: 1,
      action_type: 'like_receive',
      description: 'いいね受け取り',
      related_post: like.post
    )
    
    # デイリーミッション「5いいねする」の進捗更新
    update_daily_mission(like.user, 'likes')
    
    # ウィークリーミッション「20いいねする」の進捗更新
    update_weekly_mission(like.user, 'likes')
  end
  
  # ログイン時のポイント付与
  def self.award_for_login(user)
    # 今日初回ログインかチェック
    return unless LoginLog.first_login_today?(user)
    
    # ログイン履歴を記録
    LoginLog.record_login(user)
    
    # 連続ログイン日数を更新
    user.update_login_streak!
    
    # デイリーミッションを初期化
    user.initialize_daily_missions!
    
    # ウィークリーミッションを初期化（週初めのみ）
    if Date.current.monday?
      user.initialize_weekly_missions!
    end
    
    # デイリーログインポイント
    Point.award(
      user: user,
      amount: 5,
      action_type: 'daily_login',
      description: 'デイリーログイン'
    )
    
    # デイリーミッション「ログイン」を達成
    mission = user.todays_missions.by_type('login').first
    mission&.increment_progress!
  end
  
  private
  
  # デイリーミッションの進捗更新
  def self.update_daily_mission(user, mission_type)
    mission = user.todays_missions.by_type(mission_type).first
    return unless mission
    
    mission.increment_progress!
  end
  
  # ウィークリーミッションの進捗更新
  def self.update_weekly_mission(user, mission_type)
    mission = user.current_week_missions.by_type(mission_type).first
    return unless mission
    
    mission.increment_progress!
  end
  
  # ジャンルミッションの更新
  def self.update_genre_mission(user)
    # 今週投稿したジャンルの数を取得
    week_start = Date.current.beginning_of_week(:monday)
    genre_count = user.posts
                      .where('created_at >= ?', week_start)
                      .select(:genre_id)
                      .distinct
                      .count
    
    # ウィークリーミッション「3ジャンル制覇」を更新
    mission = user.current_week_missions.by_type('genres').first
    return unless mission
    
    mission.update!(progress: genre_count)
    mission.check_completion!
  end
end