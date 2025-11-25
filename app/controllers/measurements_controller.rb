class MeasurementsController < ApplicationController
  before_action :authenticate_user!
  
  # ===== グリット測定 =====
  
  # 測定開始画面
  def new_grit
    @measurement_type = params[:type]&.to_sym || :pre
    
    # 既に測定済みの場合は結果ページへ
    if current_user.grit_scores.send(@measurement_type).exists?
      redirect_to result_grit_measurements_path(type: @measurement_type), 
                  notice: 'この測定は既に完了しています。'
      return
    end
  end
  
  # グリット測定画面
  def grit
    @measurement_type = params[:type]&.to_sym || :pre
    @questions = GritScore::GRIT_QUESTIONS
    @answer_options = GritScore::ANSWER_OPTIONS
    @current_question = (params[:q] || 1).to_i
    
    # セッションに回答を保存
    session[:grit_answers] ||= {}
    
    # 既に測定済みの場合は結果ページへ
    if current_user.grit_scores.send(@measurement_type).exists?
      redirect_to result_grit_measurements_path(type: @measurement_type), 
                  notice: 'この測定は既に完了しています。'
      return
    end
  end
  
  # グリット測定の回答保存（1問ずつ）
  def save_grit_answer
    question_id = params[:question_id].to_i
    answer = params[:answer].to_i
    
    session[:grit_answers] ||= {}
    session[:grit_answers][question_id.to_s] = answer
    
    # 次の質問へ
    next_question = question_id + 1
    
    if next_question <= GritScore::GRIT_QUESTIONS.size
      redirect_to grit_measurements_path(q: next_question, type: params[:type])
    else
      # 全問回答完了 → スコア計算して保存
      create_grit_score
    end
  end
  
  # グリット測定結果画面
  def result_grit
    @measurement_type = params[:type]&.to_sym || :pre
    @grit_score = current_user.grit_scores.send(@measurement_type).first
    
    unless @grit_score
      redirect_to new_grit_measurements_path(type: @measurement_type), 
                  alert: '測定を完了してください。'
    end
  end
  
  # ===== ナラティブ測定 =====
  
  # 測定開始画面
  def new_narrative
    @measurement_type = params[:type]&.to_sym || :pre
    
    # 既に測定済みの場合は結果ページへ
    if current_user.narrative_scores.send(@measurement_type).exists?
      redirect_to result_narrative_measurements_path(type: @measurement_type), 
                  notice: 'この測定は既に完了しています。'
      return
    end
  end
  
  # ナラティブ測定画面
  def narrative
    @measurement_type = params[:type]&.to_sym || :pre
    @questions = NarrativeScore::NARRATIVE_QUESTIONS
    @answer_options = NarrativeScore::ANSWER_OPTIONS
    @current_question = (params[:q] || 1).to_i
    
    # セッションに回答を保存
    session[:narrative_answers] ||= {}
    
    # 既に測定済みの場合は結果ページへ
    if current_user.narrative_scores.send(@measurement_type).exists?
      redirect_to result_narrative_measurements_path(type: @measurement_type), 
                  notice: 'この測定は既に完了しています。'
      return
    end
  end
  
  # ナラティブ測定の回答保存（1問ずつ）
  def save_narrative_answer
    question_id = params[:question_id].to_i
    answer = params[:answer].to_i
    
    session[:narrative_answers] ||= {}
    session[:narrative_answers][question_id.to_s] = answer
    
    # 次の質問へ
    next_question = question_id + 1
    
    if next_question <= NarrativeScore::NARRATIVE_QUESTIONS.size
      redirect_to narrative_measurements_path(q: next_question, type: params[:type])
    else
      # 全問回答完了 → スコア計算して保存
      create_narrative_score
    end
  end
  
  # ナラティブ測定結果画面
  def result_narrative
    @measurement_type = params[:type]&.to_sym || :pre
    @narrative_score = current_user.narrative_scores.send(@measurement_type).first
    
    unless @narrative_score
      redirect_to new_narrative_measurements_path(type: @measurement_type), 
                  alert: '測定を完了してください。'
    end
  end
  
  private
  
  # グリットスコアを保存
  def create_grit_score
    answers = session[:grit_answers]
    measurement_type = params[:type]&.to_sym || :pre
    
    # スコア計算
    scores = GritScore.calculate_scores(answers)
    
    # データベースに保存
    grit_score = current_user.grit_scores.create!(
      total_score: scores[:total_score],
      consistency_score: scores[:consistency_score],
      perseverance_score: scores[:perseverance_score],
      measurement_type: measurement_type,
      answers: answers
    )
    
    # セッションクリア
    session.delete(:grit_answers)
    
    # 結果ページへ
    redirect_to result_grit_measurements_path(type: measurement_type), 
                notice: 'グリット測定が完了しました！'
  end
  
  # ナラティブスコアを保存
  def create_narrative_score
    answers = session[:narrative_answers]
    measurement_type = params[:type]&.to_sym || :pre
    
    # スコア計算
    score = NarrativeScore.calculate_score(answers)
    
    # データベースに保存
    narrative_score = current_user.narrative_scores.create!(
      score: score,
      measurement_type: measurement_type,
      answers: answers
    )
    
    # セッションクリア
    session.delete(:narrative_answers)
    
    # 結果ページへ
    redirect_to result_narrative_measurements_path(type: measurement_type), 
                notice: '物語への移入度測定が完了しました！'
  end
end