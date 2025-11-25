class Admin::DashboardController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :require_admin_login
  layout 'admin'
  
  def index
    # 統計データ取得
    @total_users = User.count
    @total_posts = Post.count
    @total_comments = Comment.count
    @total_likes = Like.count
    @total_points = Point.sum(:amount)
    
    # グリット測定完了率
    @pre_grit_completed = User.joins(:grit_scores).where(grit_scores: { measurement_type: 0 }).distinct.count
    @post_grit_completed = User.joins(:grit_scores).where(grit_scores: { measurement_type: 2 }).distinct.count
    
    # ナラティブ測定完了率
    @pre_narrative_completed = User.joins(:narrative_scores).where(narrative_scores: { measurement_type: 0 }).distinct.count
    @post_narrative_completed = User.joins(:narrative_scores).where(narrative_scores: { measurement_type: 2 }).distinct.count
    
    # 上位ユーザー
    @top_users = User.order(total_points: :desc).limit(10)
    
    # 最近の投稿
    @recent_posts = Post.includes(:user, :genre).order(created_at: :desc).limit(10)
  end
  
  private
  
  def require_admin_login
    unless session[:admin_authenticated]
      redirect_to admin_login_path, alert: '管理画面にアクセスするにはログインが必要です。'
    end
  end
end