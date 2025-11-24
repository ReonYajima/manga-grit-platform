class WeeklyMission < ApplicationRecord
  belongs_to :user
  
  validates :week_number, presence: true
  validates :week_start_date, presence: true
  validates :mission_type, presence: true
  validates :target, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # ミッション種別
  MISSION_TYPES = {
    posts: { target: 3, reward: 30, name: '3投稿する' },
    comments: { target: 10, reward: 20, name: '10コメントする' },
    likes: { target: 20, reward: 10, name: '20いいねする' },
    images: { target: 2, reward: 20, name: '画像付き投稿2回' },
    genres: { target: 3, reward: 30, name: '3ジャンル制覇' }
  }.freeze
  
  # スコープ
  scope :current_week, -> { where(week_start_date: Date.current.beginning_of_week(:monday)) }
  scope :by_type, ->(type) { where(mission_type: type) }
  scope :completed_missions, -> { where(completed: true) }
  scope :incomplete_missions, -> { where(completed: false) }
  
  # 今週のミッションを取得または作成
  def self.find_or_create_current_week_missions(user)
    week_start = Date.current.beginning_of_week(:monday)
    week_number = week_start.cweek
    
    MISSION_TYPES.each do |type, config|
      find_or_create_by!(
        user: user,
        week_start_date: week_start,
        mission_type: type.to_s
      ) do |mission|
        mission.week_number = week_number
        mission.target = config[:target]
        mission.reward_points = config[:reward]
      end
    end
  end
  
  # 進捗を更新
  def increment_progress!(amount = 1)
    transaction do
      increment!(:progress, amount)
      check_completion!
    end
  end
  
  # 達成チェック
  def check_completion!
    return if completed?
    return unless progress >= target
    
    update!(completed: true)
    
    # ポイント付与
    Point.award(
      user: user,
      amount: reward_points,
      action_type: "weekly_#{mission_type}",
      description: "ウィークリーミッション達成: #{mission_name}"
    )
  end
  
  # ミッション名
  def mission_name
    MISSION_TYPES.dig(mission_type.to_sym, :name) || mission_type
  end
  
  # 進捗率（パーセント）
  def progress_percentage
    return 0 if target.zero?
    [(progress.to_f / target * 100).round, 100].min
  end
end