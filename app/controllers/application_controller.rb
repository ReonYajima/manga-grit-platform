class ApplicationController < ActionController::Base
  # ログインが必要
  before_action :authenticate_user!
  
  # Deviseのパラメータ設定
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # ログイン追跡とポイント付与
  before_action :track_login, if: :user_signed_in?
  
  private
  
  def configure_permitted_parameters
    # ユーザー登録時（emailを削除）
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :display_name, :seminar_password, :terms_agreed])
    
    # アカウント更新時
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :display_name])
  end
  
  # ログイン追跡とポイント付与
  def track_login
    # セッションで今日初回ログインか判定
    return if session[:login_tracked_today] == Date.current.to_s
    
    # ログインポイント付与
    PointService.award_for_login(current_user)
    
    # セッションに記録
    session[:login_tracked_today] = Date.current.to_s
  end
end