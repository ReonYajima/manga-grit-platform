class Admin::ExportsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :require_admin_login
  layout 'admin'
  
  def index
    # CSV出力画面
  end
  
  # 1. ユーザー基本統計
  def users_stats
    csv_data = CsvExportService.export_users_stats
    send_csv(csv_data, 'users_stats.csv')
  end
  
  # 2. グリットスコア推移
  def grit_scores
    csv_data = CsvExportService.export_grit_scores
    send_csv(csv_data, 'grit_scores.csv')
  end
  
  # 3. ナラティブスコア推移
  def narrative_scores
    csv_data = CsvExportService.export_narrative_scores
    send_csv(csv_data, 'narrative_scores.csv')
  end
  
  # 4. 投稿詳細
  def posts
    csv_data = CsvExportService.export_posts
    send_csv(csv_data, 'posts.csv')
  end
  
  # 5. コメント詳細
  def comments
    csv_data = CsvExportService.export_comments
    send_csv(csv_data, 'comments.csv')
  end
  
  # 6. いいね詳細
  def likes
    csv_data = CsvExportService.export_likes
    send_csv(csv_data, 'likes.csv')
  end
  
  # 7. ポイント獲得履歴
  def point_logs
    csv_data = CsvExportService.export_point_logs
    send_csv(csv_data, 'point_logs.csv')
  end
  
  # 8. デイリーミッション達成履歴
  def daily_missions
    csv_data = CsvExportService.export_daily_missions
    send_csv(csv_data, 'daily_missions.csv')
  end
  
  # 9. ウィークリーミッション達成履歴
  def weekly_missions
    csv_data = CsvExportService.export_weekly_missions
    send_csv(csv_data, 'weekly_missions.csv')
  end
  
  # 10. ログイン履歴
  def login_logs
    csv_data = CsvExportService.export_login_logs
    send_csv(csv_data, 'login_logs.csv')
  end
  
  # 11. タグ使用履歴
  def tag_usage
    csv_data = CsvExportService.export_tag_usage
    send_csv(csv_data, 'tag_usage.csv')
  end
  
  # 全CSV一括出力（ZIP形式）
  def export_all
    require 'zip'
    require 'stringio'
    
    # StringIOを使ってメモリ上にZIPを作成
    stringio = Zip::OutputStream.write_buffer do |zip|
      # 1. ユーザー基本統計
      zip.put_next_entry('users_stats.csv')
      zip.write "\uFEFF" + CsvExportService.export_users_stats
      
      # 2. グリットスコア推移
      zip.put_next_entry('grit_scores.csv')
      zip.write "\uFEFF" + CsvExportService.export_grit_scores
      
      # 3. ナラティブスコア推移
      zip.put_next_entry('narrative_scores.csv')
      zip.write "\uFEFF" + CsvExportService.export_narrative_scores
      
      # 4. 投稿詳細
      zip.put_next_entry('posts.csv')
      zip.write "\uFEFF" + CsvExportService.export_posts
      
      # 5. コメント詳細
      zip.put_next_entry('comments.csv')
      zip.write "\uFEFF" + CsvExportService.export_comments
      
      # 6. いいね詳細
      zip.put_next_entry('likes.csv')
      zip.write "\uFEFF" + CsvExportService.export_likes
      
      # 7. ポイント獲得履歴
      zip.put_next_entry('point_logs.csv')
      zip.write "\uFEFF" + CsvExportService.export_point_logs
      
      # 8. デイリーミッション達成履歴
      zip.put_next_entry('daily_missions.csv')
      zip.write "\uFEFF" + CsvExportService.export_daily_missions
      
      # 9. ウィークリーミッション達成履歴
      zip.put_next_entry('weekly_missions.csv')
      zip.write "\uFEFF" + CsvExportService.export_weekly_missions
      
      # 10. ログイン履歴
      zip.put_next_entry('login_logs.csv')
      zip.write "\uFEFF" + CsvExportService.export_login_logs
      
      # 11. タグ使用履歴
      zip.put_next_entry('tag_usage.csv')
      zip.write "\uFEFF" + CsvExportService.export_tag_usage
    end
    
    # StringIOの内容を取得
    stringio.rewind
    zip_data = stringio.string
    
    # ZIPファイルとしてダウンロード
    send_data zip_data,
              filename: "all_exports_#{Date.today.strftime('%Y%m%d')}.zip",
              type: 'application/zip',
              disposition: 'attachment'
  end
  
  private
  
  def require_admin_login
    unless session[:admin_authenticated]
      redirect_to admin_login_path, alert: '管理画面にアクセスするにはログインが必要です。'
    end
  end
  
  def send_csv(csv_data, filename)
    # UTF-8 BOMを追加（Excel文字化け対策）
    csv_with_bom = "\uFEFF" + csv_data
    
    send_data csv_with_bom,
              filename: filename,
              type: 'text/csv; charset=utf-8',
              disposition: 'attachment'
  end
end