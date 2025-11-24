class AddPointsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :total_points, :integer, default: 0, null: false
    add_column :users, :login_streak, :integer, default: 0, null: false
    add_column :users, :last_login_date, :date
    
    add_index :users, :total_points
    add_index :users, :last_login_date
  end
end