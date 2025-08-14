class LikesController < ApplicationController
  # アクション実行前にPostを取得
  before_action :set_post

  # いいね作成処理
  def create
    # 既にいいねしているかチェック
    @like = @post.likes.find_by(user: current_user)
    
    unless @like
      # まだいいねしていない場合は新規作成
      @like = @post.likes.build(user: current_user)
      if @like.save
        redirect_to [@post.genre, @post], notice: 'いいねしました。'
      else
        redirect_to [@post.genre, @post], alert: 'いいねに失敗しました。'
      end
    else
      # 既にいいねしている場合
      redirect_to [@post.genre, @post], alert: '既にいいねしています。'
    end
  end

  # いいね削除処理（いいね取り消し）
  def destroy
    # 現在のユーザーのいいねを取得
    @like = @post.likes.find_by(user: current_user)
    
    if @like
      # いいねが存在する場合は削除
      @like.destroy
      redirect_to [@post.genre, @post], notice: 'いいねを取り消しました。'
    else
      # いいねが存在しない場合
      redirect_to [@post.genre, @post], alert: 'いいねしていません。'
    end
  end

  private

  # 投稿を取得する共通処理
  def set_post
    @post = Post.find(params[:post_id])
  end
end