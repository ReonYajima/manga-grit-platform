class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = current_user
    
    # デイリーミッション初期化（毎日実行）
    @user.initialize_daily_missions!
    
    # ウィークリーミッション初期化（週初めに実行）
    @user.initialize_weekly_missions!
    
    # 自分の投稿（新しい順、ページネーション付き）
    @posts = @user.posts.includes(:genre, :likes, :comments)
                  .order(created_at: :desc)
                  .page(params[:page]).per(9)  # 3列×3行 = 9件
    
    # 統計情報
    @total_posts = @user.posts.count
    @total_likes_received = Like.where(post_id: @user.posts.pluck(:id)).count
    @total_comments_received = Comment.where(post_id: @user.posts.pluck(:id)).count
    
    # 自分がいいねした投稿（最新5件）
    @liked_posts = Post.joins(:likes)
                       .where(likes: { user_id: @user.id })
                       .includes(:user, :genre)
                       .order('likes.created_at DESC')
                       .limit(5)
    
    # 使用タグランキング（Top 5）
    tag_counts = {}
    @user.posts.each do |post|
      post.tag_list.each do |tag|
        tag_counts[tag] ||= 0
        tag_counts[tag] += 1
      end
    end
    @top_tags = tag_counts.sort_by { |_, count| -count }.first(5)
    
    # 登録日からの日数
    @days_since_signup = (Date.today - @user.created_at.to_date).to_i

    # ===== 追加: スコア推移データ取得 =====
    @pre_grit_score = @user.grit_scores.pre.first
    @post_grit_score = @user.grit_scores.post.first
    @pre_narrative_score = @user.narrative_scores.pre.first
    @post_narrative_score = @user.narrative_scores.post.first
  end
end
