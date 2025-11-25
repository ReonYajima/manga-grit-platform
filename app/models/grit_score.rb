class GritScore < ApplicationRecord
  belongs_to :user
  
  # measurement_type の enum
  enum measurement_type: { pre: 0, mid: 1, post: 2 }
  
  # バリデーション
  validates :total_score, presence: true, 
            numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 4.0 }
  validates :consistency_score, presence: true,
            numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 4.0 }
  validates :perseverance_score, presence: true,
            numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 4.0 }
  validates :measurement_type, presence: true
  validates :answers, presence: true
  
  # 1ユーザーにつき各測定タイプは1回まで
  validates :measurement_type, uniqueness: { scope: :user_id }
  
  # グリット質問（12問）
  GRIT_QUESTIONS = [
    # 興味の一貫性（逆転項目）
    { id: 1, text: "新しいアイディアや計画によって、それまで取り組んでいたことから注意がそれることがある。", reverse: true, category: :consistency },
    { id: 2, text: "あるアイディアや計画に一時的に夢中になっても、あとで興味を失うことがある。", reverse: true, category: :consistency },
    { id: 3, text: "数ヶ月以上かかるような計画に集中し続けることが苦手である。", reverse: true, category: :consistency },
    { id: 4, text: "私の興味は年々変わる。", reverse: true, category: :consistency },
    { id: 5, text: "目標を決めても、後から変えてしまうことがよくある。", reverse: true, category: :consistency },
    { id: 6, text: "数ヶ月ごとに新しい活動への興味が湧いてくる。", reverse: true, category: :consistency },
    
    # 努力の粘り強さ（通常項目）
    { id: 7, text: "私は精魂尽けるものごとに取り組む。", reverse: false, category: :perseverance },
    { id: 8, text: "重要な試練に打ち勝つため、挫折を乗り越えてきた。", reverse: false, category: :perseverance },
    { id: 9, text: "数年にわたる努力を要する目標を達成したことがある。", reverse: false, category: :perseverance },
    { id: 10, text: "私は努力家だ。", reverse: false, category: :perseverance },
    { id: 11, text: "始めたことは、どんなことでも必ず最後までやり遂げる。", reverse: false, category: :perseverance },
    { id: 12, text: "困難があっても、私はやる気を失わない。", reverse: false, category: :perseverance }
  ]
  
  # 回答選択肢
  ANSWER_OPTIONS = [
    { value: 1, label: "いつもそうする" },
    { value: 2, label: "ときどきそうする" },
    { value: 3, label: "あまりそうしない" },
    { value: 4, label: "ぜんぜんそうしない" }
  ]
  
  # スコア計算
  def self.calculate_scores(answers)
    consistency_items = [1, 2, 3, 4, 5, 6]
    perseverance_items = [7, 8, 9, 10, 11, 12]
    
    # スコア変換（逆転項目: 1→4, 2→3, 3→2, 4→1）
    # 通常項目: 1→4, 2→3, 3→2, 4→1
    converted_scores = answers.transform_values do |answer|
      5 - answer.to_i  # 1→4, 2→3, 3→2, 4→1
    end
    
    # 興味の一貫性スコア
    consistency_score = consistency_items.sum { |i| converted_scores[i.to_s].to_f } / consistency_items.size
    
    # 努力の粘り強さスコア
    perseverance_score = perseverance_items.sum { |i| converted_scores[i.to_s].to_f } / perseverance_items.size
    
    # 総合スコア
    total_score = (consistency_score + perseverance_score) / 2.0
    
    {
      total_score: total_score.round(2),
      consistency_score: consistency_score.round(2),
      perseverance_score: perseverance_score.round(2)
    }
  end
  
  # 測定タイプの日本語名
  def measurement_type_name
    case measurement_type
    when 'pre' then '事前測定'
    when 'mid' then '中間測定'
    when 'post' then '事後測定'
    end
  end
  
  # スコアの評価コメント
  def evaluation_comment
    if total_score >= 3.5
      "あなたのグリットスコアは高いです。困難に直面しても諦めず、長期的な目標に向かって努力を続ける力があります。"
    elsif total_score >= 2.5
      "あなたのグリットスコアは平均的です。継続的な努力を心がけることで、さらに成長できます。"
    else
      "あなたのグリットスコアは低めです。小さな目標から始めて、達成感を積み重ねていきましょう。"
    end
  end
  
  # 興味の一貫性の評価
  def consistency_evaluation
    if consistency_score >= 3.5
      "興味が一貫しており、長期的な目標に集中できています。"
    elsif consistency_score >= 2.5
      "興味の一貫性は平均的です。目標を明確にすることで改善できます。"
    else
      "興味が変わりやすい傾向があります。1つのことに集中する時間を作りましょう。"
    end
  end
  
  # 努力の粘り強さの評価
  def perseverance_evaluation
    if perseverance_score >= 3.5
      "困難に直面しても諦めず、粘り強く努力を続ける力があります。"
    elsif perseverance_score >= 2.5
      "努力の粘り強さは平均的です。小さな成功体験を積み重ねましょう。"
    else
      "困難に直面すると諦めやすい傾向があります。小さな目標から始めましょう。"
    end
  end
end