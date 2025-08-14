# ジャンルの初期データを作成
genres = [
  {
    name: "自己実現",
    description: "成長・目標達成"
  },
  {
    name: "知識・学習",
    description: "勉強・スキル向上"
  },
  {
    name: "情動・感情",
    description: "感情・心の成長"
  },
  {
    name: "困難克服",
    description: "逆境・チャレンジ"
  },
  {
    name: "人間関係",
    description: "友情・恋愛・家族"
  },
  {
    name: "その他",
    description: "多様なジャンル"
  }
]

# ジャンルを作成（重複チェック付き）
genres.each do |genre_data|
  Genre.find_or_create_by(name: genre_data[:name]) do |genre|
    genre.description = genre_data[:description]
  end
end

puts "#{Genre.count}個のジャンルを作成しました"