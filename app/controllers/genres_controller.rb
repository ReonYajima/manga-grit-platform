class GenresController < ApplicationController
  def index
    @genres = Genre.all
    
    # ===== トップページ用の統計データ =====
    
    # 1. 全体統計
    @total_posts = Post.count
    @total_users = User.count
    @total_comments = Comment.count
    @total_likes = Like.count
    
    # 2. ジャンル別投稿数（円グラフ用）
    @genre_stats = Genre.left_joins(:posts)
                        .select('genres.*, COUNT(posts.id) as posts_count')
                        .group('genres.id')
                        .order('posts_count DESC')
    
    # 3. 人気のタグ Top 10
    tag_counts = {}
    Post.all.each do |post|
      post.tag_list.each do |tag|
        tag_counts[tag] ||= 0
        tag_counts[tag] += 1
      end
    end
    @top_tags = tag_counts.sort_by { |_, count| -count }.first(10)
    
    # 4. 最近の投稿 5件
    @recent_posts = Post.includes(:user, :genre, :likes, :comments)
                        .order(created_at: :desc)
                        .limit(5)
    
    # 5. ポイントランキング Top 5（追加）
    @top_users = User.where('total_points > 0')
                     .order(total_points: :desc)
                     .includes(:posts)
                     .limit(5)
  end

  def show
    @genre = Genre.find(params[:id])
    @posts = @genre.posts.includes(:user, :likes, :comments)
                  .order(created_at: :desc)
                  .page(params[:page]).per(12)
  end
end
