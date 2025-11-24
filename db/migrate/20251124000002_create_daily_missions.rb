class CreateDailyMissions < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_missions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :mission_date, null: false
      t.string :mission_type, null: false
      t.boolean :completed, default: false
      t.integer :progress, default: 0
      t.integer :target, null: false
      t.integer :reward_points, default: 0
      
      t.timestamps
    end
    
    add_index :daily_missions, [:user_id, :mission_date, :mission_type], 
              unique: true, name: 'index_daily_missions_unique'
    add_index :daily_missions, :mission_date
  end
end