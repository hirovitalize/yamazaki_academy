# frozen_string_literal: false

require 'base64'
require 'json'

# rubocop:disable Metrics/LineLength
class AttendsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_lecture,
                only: %i[show]
  skip_before_action :authenticate_user!, only: %i[check checked]
  skip_before_action :basic_auth, only: %i[check checked]

  # GET /attends/
  def show
    @url = build_url(@lecture)
  end

  # GET /attends/check
  def check
    build_log.save

    Lecture.find(build_log.lecture_id).approve!

    # 過剰アクセス防止のため、リダイレクト
    redirect_to attends_checked_path
  end

  # GET /attends/checked
  def checked
    flash[:notice] = '確認できました。ご協力ありがとうございました。'
    render layout: false
  end

  private

  def build_url(lecture)
    student_id = lecture.student_ids.size == 1 ? lecture.student_ids.first : nil
    queries = { lecture_id: lecture.id, student_id: student_id, qr_made_at: Time.zone.now }
    # url = attends_check_url(**queries)
    url = attends_check_url(token: Base64.encode64(JSON.generate(queries)))

    url
  end

  def build_log
    p = JSON.parse(Base64.decode64(params[:token]), symbolize_names: true)
    # p = params.permit!

    log = LectureAttendLog.new(
      lecture_id: p[:lecture_id],
      student_id: p[:student_id],
      qr_made_at: p[:qr_made_at],
      prev_cookie_student_ids: set_cookies_student(cookies, p),
      ip: request.remote_ip,
      ua: request.user_agent
    )
    log.prepare_validation_note

    cookies.permanent.signed[:student_id] = {
      value: set_cookies_student(cookies, p),
      expires: 1.year.from_now
    }

    log
  end

  def set_cookies_student(cookie, param)
    cookie.signed[:student_id].blank? ? param[:student_id] : [param[:student_id].to_s, cookie.signed[:student_id].to_s.split(',')].flatten.compact.uniq.join(',')
  end

  def set_lecture
    @lecture = Lecture.with_deleted.find(params[:id])
  end
end
# rubocop:enable Metrics/LineLength
