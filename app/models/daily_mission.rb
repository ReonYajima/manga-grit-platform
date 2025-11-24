class DailyMission < ApplicationRecord
  belongs_to :user
  
  validates :mission_date, presence: true
  validates :mission_type, presence: true
  validates :target, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # ミッション種別
  MISSION_TYPES = {
    login: { target: 1, reward: 5, name: 'デイリーログイン' },
    post: { target: 1, reward: 10, name: '1投稿する' },
    comments: { target: 3, reward: 10, name: '3コメントする' },
    likes: { target: 5, reward: 5, name: '5いいねする' }
  }.freeze
  
  # スコープ
  scope :today, -> { where(mission_date: Date.current) }
  scope :by_type, ->(type) { where(mission_type: type) }
  scope :completed_missions, -> { where(completed: true) }
  scope :incomplete_missions, -> { where(completed: false) }
  
  # 今日のミッションを取得または作成
  def self.find_or_create_today_missions(user)
    MISSION_TYPES.each do |type, config|
      find_or_create_by!(
        user: user,
        mission_date: Date.current,
        mission_type: type.to_s
      ) do |mission|
        mission.target = config[:target]
        mission.reward_points = config[:reward]
      end
    end
  end
  
  # 進捗を更新
  def increment_progress!
    transaction do
      increment!(:progress)
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
      action_type: "daily_#{mission_type}",
      description: "デイリーミッション達成: #{mission_name}"
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