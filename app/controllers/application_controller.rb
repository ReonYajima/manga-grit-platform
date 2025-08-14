class ApplicationController < ActionController::Base
  # ログインが必要
  before_action :authenticate_user!
  
  # Deviseのパラメータ設定
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  private
  
  def configure_permitted_parameters
    # ユーザー登録時に username と display_name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :display_name])
    # アカウント更新時に username と display_name を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :display_name])
  end
end