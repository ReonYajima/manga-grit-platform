class RankingController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @users = User.where('total_points > 0')
                 .order(total_points: :desc)
                 .includes(:posts, :comments, :likes)
    
    @current_user_rank = current_user.points_rank
  end
end