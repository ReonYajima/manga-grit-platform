class NarrativeScore < ApplicationRecord
  belongs_to :user
  
  # measurement_type の enum
  enum measurement_type: { pre: 0, mid: 1, post: 2 }
  
  # バリデーション
  validates :score, presence: true,
            numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 7.0 }
  validates :measurement_type, presence: true
  validates :answers, presence: true
  
  # 1ユーザーにつき各測定タイプは1回まで
  validates :measurement_type, uniqueness: { scope: :user_id }
  
  # 物語への移入尺度 質問（6問）
  NARRATIVE_QUESTIONS = [
    { id: 1, text: "マンガで描かれている場面に自分がいるように感じることが多い" },
    { id: 2, text: "マンガを読んでいるあいだ、物語に入り込んでいるように感じることが多い" },
    { id: 3, text: "読んでいるとき、この物語の結末を知りたいと思うことが多い" },
    { id: 4, text: "マンガは自分の感情に影響を与えることが多い" },
    { id: 5, text: "キャラクターの様子をはっきりとイメージすることができる" },
    { id: 6, text: "登場人物の様子をはっきりとイメージすることができる" }
  ]
  
  # 回答選択肢（7段階）
  ANSWER_OPTIONS = [
    { value: 1, label: "全くあてはまらない" },
    { value: 2, label: "あてはまらない" },
    { value: 3, label: "あまりあてはまらない" },
    { value: 4, label: "どちらともいえない" },
    { value: 5, label: "ややあてはまる" },
    { value: 6, label: "あてはまる" },
    { value: 7, label: "非常にあてはまる" }
  ]
  
  # スコア計算
  def self.calculate_score(answers)
    # 全6問の平均（1〜7点）
    total = answers.values.sum(&:to_f)
    score = total / answers.size
    score.round(2)
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
    if score >= 6.0
      "あなたは物語の世界に非常に入り込みやすいタイプです。マンガを読むことで深い感情体験を得られています。"
    elsif score >= 5.0
      "あなたは物語の世界に入り込みやすいタイプです。マンガのストーリーから多くの学びを得られるでしょう。"
    elsif score >= 4.0
      "あなたの物語への移入度は平均的です。じっくり読むことでより深い体験が得られます。"
    else
      "あなたは物語の世界に入り込みにくい傾向があります。お気に入りのマンガを見つけることから始めましょう。"
    end
  end
end