Rails.application.routes.draw do
  # Devise（ユーザー認証）のルーティング
  devise_for :users

  # トップページをジャンル一覧に設定
  root "genres#index"

  # ジャンル関連のルーティング
  resources :genres, only: [ :index, :show ] do
    # ジャンル内での投稿関連ルーティング
    resources :posts, except: [ :index ]
  end

  # 投稿に対するコメントといいね機能
  resources :posts, only: [] do
    resources :comments, only: [ :create, :destroy ]
    resources :likes, only: [ :create, :destroy ]
  end
end