# frozen_string_literal: true

class LectureAttendLogsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_lecture_attend_log, only: %i[show]
  before_action -> { check_authorize(@lecture_attend_log, controller_name) }, only: %i[index show]
  skip_before_action :authenticate_user!, only: %i[clear_cookies cleared]
  skip_before_action :basic_auth, only: %i[clear_cookies cleared]

  # GET /lecture_attend_logs
  def index
    @q = LectureAttendLog.all.order(id: :desc).ransack(params[:q])
    @lecture_attend_logs = @q.result.page(params[:page]).includes(:student, lecture: [lecture_staffs: [:staff]])
    respond_with(@lecture_attend_logs)
  end

  # GET /lecture_attend_logs/1
  def show
    respond_with(@lecture_attend_log)
  end

  def build_clear_url
    @url = clear_cookies_lecture_attend_logs_url
  end

  def clear_cookies
    cookies.permanent.signed[:student_id] = { value: '' }

    redirect_to cleared_lecture_attend_logs_path
  end

  def cleared
    flash[:notice] = '初期化できました。ご協力ありがとうございました。'
    render layout: false
  end

  private

  def set_lecture_attend_log
    @lecture_attend_log = LectureAttendLog.with_deleted.find(params[:id])
  end
end
