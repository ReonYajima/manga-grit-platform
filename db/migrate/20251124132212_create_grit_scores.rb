class CreateGritScores < ActiveRecord::Migration[7.1]
  def change
    create_table :grit_scores do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_score, precision: 4, scale: 2, null: false       # 1.00〜4.00
      t.decimal :consistency_score, precision: 4, scale: 2              # 興味の一貫性
      t.decimal :perseverance_score, precision: 4, scale: 2             # 努力の粘り強さ
      t.integer :measurement_type, null: false, default: 0              # 0: 事前, 1: 中間, 2: 事後
      t.json :answers                                                   # 回答データ（JSON形式）
      t.timestamps
    end

    add_index :grit_scores, [:user_id, :measurement_type], unique: true
    add_index :grit_scores, :created_at
  end
end