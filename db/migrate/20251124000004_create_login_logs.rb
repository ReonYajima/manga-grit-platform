class CreateLoginLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :login_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :login_at, null: false
      
      t.timestamps
    end
    
    add_index :login_logs, [:user_id, :login_at]
  end
end