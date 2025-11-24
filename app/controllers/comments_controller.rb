class CommentsController < ApplicationController
  # アクション実行前にPostを取得
  before_action :set_post

  # コメント作成処理
  def create
    # 現在のユーザーと投稿を関連付けてコメントを作成
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # ポイント付与
      PointService.award_for_comment_create(@comment)
      
      # 保存成功時は投稿詳細画面にリダイレクト
      redirect_to [@post.genre, @post], notice: 'コメントが投稿されました。'
    else
      # 保存失敗時は投稿詳細画面にリダイレクト（エラーメッセージ付き）
      redirect_to [@post.genre, @post], alert: 'コメントの投稿に失敗しました。'
    end
  end

  # コメント削除処理
  def destroy
    # 削除対象のコメントを取得
    @comment = @post.comments.find(params[:id])
    
    # コメント投稿者本人以外は削除不可
    unless @comment.user == current_user
      redirect_to [@post.genre, @post], alert: '削除権限がありません。'
      return
    end

    @comment.destroy
    # 削除後は投稿詳細画面にリダイレクト
    redirect_to [@post.genre, @post], notice: 'コメントが削除されました。'
  end

  private

  # 投稿を取得する共通処理
  def set_post
    @post = Post.find(params[:post_id])
  end

  # コメント作成で許可するパラメータ
  def comment_params
    params.require(:comment).permit(:content)
  end
end