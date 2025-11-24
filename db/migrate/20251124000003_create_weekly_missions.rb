class CreateWeeklyMissions < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_missions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :week_number, null: false
      t.date :week_start_date, null: false
      t.string :mission_type, null: false
      t.boolean :completed, default: false
      t.integer :progress, default: 0
      t.integer :target, null: false
      t.integer :reward_points, default: 0
      
      t.timestamps
    end
    
    add_index :weekly_missions, [:user_id, :week_number, :mission_type], 
              unique: true, name: 'index_weekly_missions_unique'
    add_index :weekly_missions, :week_start_date
  end
end