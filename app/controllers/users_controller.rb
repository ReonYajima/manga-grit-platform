class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = current_user
    
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
  end
end