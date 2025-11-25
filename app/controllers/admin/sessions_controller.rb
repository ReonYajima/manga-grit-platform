class Admin::SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'admin'
  
  def new
    # ログイン画面表示
  end
  
  def create
    if params[:password] == ENV.fetch('ADMIN_PASSWORD', 'kawano_admin_2024')
      session[:admin_authenticated] = true
      redirect_to admin_dashboard_path, notice: '管理画面にログインしました。'
    else
      flash.now[:alert] = 'パスワードが正しくありません。'
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session.delete(:admin_authenticated)
    redirect_to root_path, notice: 'ログアウトしました。'
  end
end