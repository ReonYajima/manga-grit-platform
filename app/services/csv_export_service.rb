require 'csv'

class CsvExportService
  class << self
    # 1. ユーザー基本統計
    def export_users_stats
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '表示名',
          '登録日',
          '投稿数',
          'コメント数',
          '送ったいいね数',
          '受け取ったいいね数',
          'ログイン日数',
          '総ポイント',
          'デイリーミッション達成回数',
          'ウィークリーミッション達成回数'
        ]
        
        User.find_each do |user|
          csv << [
            user.username,
            user.display_name,
            user.created_at.strftime('%Y-%m-%d'),
            user.posts.count,
            user.comments.count,
            user.likes.count,
            Like.where(post_id: user.posts.pluck(:id)).count,
            user.login_logs.select(:login_at).distinct.count,
            user.total_points,
            user.daily_missions.where(completed: true).count,
            user.weekly_missions.where(completed: true).count
          ]
        end
      end
    end
    
    # 2. グリットスコア推移
    def export_grit_scores
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '測定日時',
          'グリットスコア',
          '興味の一貫性スコア',
          '努力の粘り強さスコア',
          '測定回数'
        ]
        
        GritScore.includes(:user).find_each do |score|
          csv << [
            score.user.username,
            score.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            score.total_score,
            score.consistency_score,
            score.perseverance_score,
            score.measurement_type_before_type_cast == 0 ? '事前' : '事後'
          ]
        end
      end
    end
    
    # 3. ナラティブスコア推移
    def export_narrative_scores
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '測定日時',
          'ナラティブスコア',
          '測定回数'
        ]
        
        NarrativeScore.includes(:user).find_each do |score|
          csv << [
            score.user.username,
            score.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            score.score,
            score.measurement_type_before_type_cast == 0 ? '事前' : '事後'
          ]
        end
      end
    end
    
    # 4. 投稿詳細
    def export_posts
      CSV.generate(headers: true) do |csv|
        csv << [
          '投稿ID',
          '投稿者',
          'マンガタイトル',
          'ジャンル',
          '投稿日時',
          '画像あり',
          'タグ数',
          'タグ内容',
          '本文文字数',
          'いいね数',
          'コメント数',
          '出典情報あり'
        ]
        
        Post.includes(:user, :genre, :likes, :comments).find_each do |post|
          csv << [
            post.id,
            post.user.username,
            post.manga_title,
            post.genre.name,
            post.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            post.image.attached? ? 'あり' : 'なし',
            post.tag_list.count,
            post.tag_list.join(', '),
            post.content.length,
            post.likes.count,
            post.comments.count,
            post.manga_author.present? ? 'あり' : 'なし'
          ]
        end
      end
    end
    
    # 5. コメント詳細
    def export_comments
      CSV.generate(headers: true) do |csv|
        csv << [
          'コメントID',
          '投稿ID',
          'コメント者',
          '投稿者',
          '日時',
          '文字数'
        ]
        
        Comment.includes(:user, post: :user).find_each do |comment|
          csv << [
            comment.id,
            comment.post_id,
            comment.user.username,
            comment.post.user.username,
            comment.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            comment.content.length
          ]
        end
      end
    end
    
    # 6. いいね詳細
    def export_likes
      CSV.generate(headers: true) do |csv|
        csv << [
          'いいねID',
          '投稿ID',
          'いいねした人',
          '投稿者',
          '日時'
        ]
        
        Like.includes(:user, post: :user).find_each do |like|
          csv << [
            like.id,
            like.post_id,
            like.user.username,
            like.post.user.username,
            like.created_at.strftime('%Y-%m-%d %H:%M:%S')
          ]
        end
      end
    end
    
    # 7. ポイント獲得履歴
    def export_point_logs
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '日時',
          '行動種別',
          '獲得ポイント',
          '累計ポイント',
          '説明'
        ]
        
        Point.includes(:user).order(:created_at).find_each do |point|
          csv << [
            point.user.username,
            point.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            point.action_type_name,
            point.amount,
            point.user.points.where('created_at <= ?', point.created_at).sum(:amount),
            point.description
          ]
        end
      end
    end
    
    # 8. デイリーミッション達成履歴
    def export_daily_missions
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '日付',
          'ミッション内容',
          '達成状態',
          '進捗',
          '目標',
          'ボーナスポイント'
        ]
        
        DailyMission.includes(:user).find_each do |mission|
          csv << [
            mission.user.username,
            mission.mission_date.strftime('%Y-%m-%d'),
            mission.mission_name,
            mission.completed ? '達成' : '未達成',
            mission.progress,
            mission.target,
            mission.reward_points
          ]
        end
      end
    end
    
    # 9. ウィークリーミッション達成履歴
    def export_weekly_missions
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '週番号',
          '週開始日',
          'ミッション内容',
          '達成状態',
          '進捗',
          '目標',
          'ボーナスポイント'
        ]
        
        WeeklyMission.includes(:user).find_each do |mission|
          csv << [
            mission.user.username,
            mission.week_number,
            mission.week_start_date.strftime('%Y-%m-%d'),
            mission.mission_name,
            mission.completed ? '達成' : '未達成',
            mission.progress,
            mission.target,
            mission.reward_points
          ]
        end
      end
    end
    
    # 10. ログイン履歴
    def export_login_logs
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          '日時',
          '曜日',
          '時間帯'
        ]
        
        LoginLog.includes(:user).find_each do |log|
          csv << [
            log.user.username,
            log.login_at.strftime('%Y-%m-%d %H:%M:%S'),
            %w[日 月 火 水 木 金 土][log.login_at.wday],
            log.login_at.hour < 12 ? '午前' : '午後'
          ]
        end
      end
    end
    
    # 11. タグ使用履歴
    def export_tag_usage
      CSV.generate(headers: true) do |csv|
        csv << [
          'ユーザー名',
          'タグ名',
          '使用回数'
        ]
        
        User.find_each do |user|
          tag_counts = {}
          user.posts.each do |post|
            post.tag_list.each do |tag|
              tag_counts[tag] ||= 0
              tag_counts[tag] += 1
            end
          end
          
          tag_counts.each do |tag, count|
            csv << [user.username, tag, count]
          end
        end
      end
    end
  end
end