Rails.application.routes.draw do
  # Devise（ユーザー認証）のルーティング
  devise_for :users

  # トップページをジャンル一覧に設定
  root "genres#index"

  # 利用規約ページ（サインアップ前に必ず表示）
  get 'terms', to: 'pages#terms'
  
  # 新規登録の前に利用規約ページへリダイレクト
  get 'signup', to: 'pages#signup_redirect'

  # マイページ
  get 'mypage', to: 'users#show', as: 'mypage'

  # ランキングページ
  get 'ranking', to: 'ranking#index'

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

  # 測定機能
  resources :measurements, only: [] do
    collection do
      # グリット測定
      get 'grit/new', action: :new_grit, as: :new_grit
      get 'grit', action: :grit
      post 'grit/save', action: :save_grit_answer
      get 'grit/result', action: :result_grit, as: :result_grit
    
      # ナラティブ測定
      get 'narrative/new', action: :new_narrative, as: :new_narrative
      get 'narrative', action: :narrative
      post 'narrative/save', action: :save_narrative_answer
      get 'narrative/result', action: :result_narrative, as: :result_narrative
    end
  end

  # 管理画面
  namespace :admin do
    # ログイン関連
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    
    # ダッシュボード
    get 'dashboard', to: 'dashboard#index'
    
    # CSV出力画面
    get 'exports', to: 'exports#index'
    
    # 個別CSV出力
    post 'exports/users_stats', to: 'exports#users_stats'
    post 'exports/grit_scores', to: 'exports#grit_scores'
    post 'exports/narrative_scores', to: 'exports#narrative_scores'
    post 'exports/posts', to: 'exports#posts'
    post 'exports/comments', to: 'exports#comments'
    post 'exports/likes', to: 'exports#likes'
    post 'exports/point_logs', to: 'exports#point_logs'
    post 'exports/daily_missions', to: 'exports#daily_missions'
    post 'exports/weekly_missions', to: 'exports#weekly_missions'
    post 'exports/login_logs', to: 'exports#login_logs'
    post 'exports/tag_usage', to: 'exports#tag_usage'
    
    # 全CSV一括出力
    post 'exports/all', to: 'exports#export_all'
  end
end