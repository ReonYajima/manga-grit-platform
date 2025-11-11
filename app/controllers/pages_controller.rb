class PagesController < ApplicationController
  # 利用規約ページはログイン不要
  skip_before_action :authenticate_user!
  
  def terms
  end
  
  def signup_redirect
    # 利用規約ページにリダイレクト
    redirect_to terms_path(from_signup: true)
  end
end