class CreateNarrativeScores < ActiveRecord::Migration[7.1]
  def change
    create_table :narrative_scores do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :score, precision: 4, scale: 2, null: false             # 1.00〜7.00
      t.integer :measurement_type, null: false, default: 0              # 0: 事前, 1: 中間, 2: 事後
      t.json :answers
      t.timestamps
    end

    add_index :narrative_scores, [:user_id, :measurement_type], unique: true
    add_index :narrative_scores, :created_at
  end
end