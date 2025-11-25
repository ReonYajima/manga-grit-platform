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
end