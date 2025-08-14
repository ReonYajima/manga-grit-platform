class GenresController < ApplicationController
  # ジャンル一覧画面（トップページ）
  def index
    # 全てのジャンルを取得してビューに渡す
    @genres = Genre.all
  end

  # 特定ジャンルの投稿一覧画面
  def show
    # URLパラメータからジャンルを取得
    @genre = Genre.find(params[:id])
    # そのジャンルの投稿を最新順で取得（ページネーション機能付き）
    @posts = @genre.posts.includes(:user, :tags).order(created_at: :desc).page(params[:page]).per(10)
  end
end