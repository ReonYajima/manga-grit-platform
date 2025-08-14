class PostsController < ApplicationController
  # アクション実行前にPostを取得
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  # アクション実行前にGenreを取得
  before_action :set_genre, only: [:new, :create]

  # 投稿詳細画面
  def show
    # コメントを作成日時順で取得
    @comments = @post.comments.includes(:user).order(:created_at)
    # 新しいコメント用のオブジェクト
    @comment = Comment.new
  end

  # 新規投稿画面
  def new
    # 新しい投稿オブジェクトを作成
    @post = @genre.posts.build
  end

  # 投稿作成処理
  def create
    # 現在のユーザーとジャンルを関連付けて投稿を作成
    @post = @genre.posts.build(post_params)
    @post.user = current_user

    if @post.save
      # 保存成功時はジャンル画面にリダイレクト
      redirect_to @genre, notice: '投稿が作成されました。'
    else
      # 保存失敗時は新規作成画面を再表示
      render :new, status: :unprocessable_entity
    end
  end

  # 投稿編集画面
  def edit
    # 投稿者本人以外は編集不可
    redirect_to [@post.genre, @post], alert: '編集権限がありません。' unless @post.user == current_user
  end

  # 投稿更新処理
  def update
    # 投稿者本人以外は更新不可
    unless @post.user == current_user
      redirect_to [@post.genre, @post], alert: '編集権限がありません。'
      return
    end

    if @post.update(post_params)
      # 更新成功時は投稿詳細画面にリダイレクト
      redirect_to [@post.genre, @post], notice: '投稿が更新されました。'
    else
      # 更新失敗時は編集画面を再表示
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿削除処理
  def destroy
    # 投稿者本人以外は削除不可
    unless @post.user == current_user
      redirect_to [@post.genre, @post], alert: '削除権限がありません。'
      return
    end

    genre = @post.genre
    @post.destroy
    # 削除後はジャンル画面にリダイレクト
    redirect_to genre, notice: '投稿が削除されました。'
  end

  private

  # 投稿を取得する共通処理
  def set_post
    @post = Post.find(params[:id])
  end

  # ジャンルを取得する共通処理
  def set_genre
    @genre = Genre.find(params[:genre_id])
  end

  # 投稿作成・更新で許可するパラメータ
  def post_params
    params.require(:post).permit(:manga_title, :content, :tag_list)
  end
end