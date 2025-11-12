class GenresController < ApplicationController
  # ジャンル一覧画面（トップページ）
  def index
    # 全てのジャンルを取得してビューに渡す
    @genres = Genre.all


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
  end

  # 特定ジャンルの投稿一覧画面
  def show
    # URLパラメータからジャンルを取得
    @genre = Genre.find(params[:id])
    # そのジャンルの投稿を最新順で取得（ページネーション機能付き）
    @posts = @genre.posts.includes(:user, :tags).order(created_at: :desc).page(params[:page]).per(10)
  end
end