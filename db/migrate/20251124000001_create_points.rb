class CreatePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :points do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false, default: 0
      t.string :action_type, null: false
      t.references :related_post, foreign_key: { to_table: :posts }, null: true
      t.references :related_comment, foreign_key: { to_table: :comments }, null: true
      t.text :description
      
      t.timestamps
    end
    
    add_index :points, :action_type
    add_index :points, :created_at
  end
end