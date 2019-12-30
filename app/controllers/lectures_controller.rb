# frozen_string_literal: false

require 'icalendar'
require 'icalendar/tzinfo'

# rubocop:disable Metrics/ClassLength
class LecturesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_lecture,
                only: %i[show destroy reserve_by_lecture approve unapprove back_confirmed cancel change_request_for_vip]
  before_action :init_lecture, only: %i[new create]
  before_action :edit_lecture, only: %i[edit update duplicate]
  before_action -> { check_authorize(@lecture, controller_name) },
                only: %i[index new create edit update destroy duplicate approve unapprove back_confirmed cancel]
  skip_before_action :authenticate_user!, only: [:icalendar]
  skip_before_action :basic_auth, only: [:icalendar]
  # GET /lectures
  def index
    @q = Lecture.all.order(id: :desc).ransack(params[:q])
    @lectures = @q.result(distinct: true).page(params[:page]).includes(:lecture_staffs, :staffs, :subject, :confirmer, :tags, :lecture_attend_logs,
                                                                       reserve: [:room],
                                                                       klass_subject: %i[klass subject])

    if params.key? :reserve_by_lectures
      redirect_to calendar_reserves_path(
        l: params.require(:q).permit! || {},
        start_date: [@q.result.minimum('start_time').try(:to_date), Time.zone.today].compact.max
      )
      return
    end

    if params.key? :export_ical
      calendar = ical(@q.result)
      headers['Content-Type'] = 'text/calendar; charset=UTF-8'
      render plain: calendar.to_ical
      return
    end

    if params.key? :duplicate_lectures
      ids = @q.result.pluck(:id)
      redirect_to action: 'confirm_lecture', lecture_ids: ids
      return
    end

    respond_with(@lectures)
  end

  # GET /klass_calendar
  # 読み取り専用画面
  def klass_calendar
    @start_date = params[:start_date].presence || Time.zone.today
    @end_date = params[:end_date].presence || (Time.zone.parse(@start_date.to_s) + 1.day)

    @lectures = lectures_for_klasses(@start_date, @end_date, klass_subject_id_not_null: 1)

    # params[:r]
    @r = klass_ransack
    @klass_ids = @r.result.ids.uniq

    gon.date = @start_date

    respond_with(@lectures)
  end

  # GET /staff_calendar
  # 読み取り専用画面
  def staff_calendar
    @start_date = params[:start_date].presence || Time.zone.today
    @end_date = params[:end_date].presence || (Time.zone.parse(@start_date.to_s) + 6.days)

    @lectures = lectures_for_staffs(@start_date, @end_date)

    # params[:r]
    @r = staff_ransack
    @staff_ids = @r.result.ids.uniq
    @staff_ids &= @lectures.map(&:staff_id).uniq

    gon.date = @start_date

    respond_with(@lectures)
  end

  # GET /lectures/1
  def show
    respond_with(@lecture)
  end

  def reserve_by_lecture
    area_id = @lecture.klass_subject&.klass&.area_id
    redirect_to calendar_reserves_path(
      l: { id_in: params[:id] },
      r: {
        building_area_id_in: (@lecture.subject&.personal ? [1, 2] : area_id),
        building_id_in: ([15, 10, 11, 13, 16, 17, 19] if @lecture.subject&.personal),
        id_in: ([10, 18, 35, 36, 37, 38, 41, 42, 51, 201, 202, 203, 204, 205, 211, 404, 407, 408, 409, 410, 412, 415, 417, 420] if @lecture.subject&.personal)
      },
      start_date: @lecture.start_time.to_date
    )
  end

  # GET /lectures/new
  def new
    respond_with(@lecture)
  end

  # GET /lectures/1/edit
  def edit
    respond_with(@lecture)
  end

  # POST /lectures
  def create
    @lecture.save
    respond_with(@lecture)
  end

  # PATCH/PUT /lectures/1
  def update
    @lecture.reserve&.mark_for_destruction if @lecture.start_time_changed? || @lecture.finish_time_changed?
    @lecture.save
    respond_with(@lecture)
  end

  # DELETE /lectures/1
  def destroy
    @lecture.destroy
    respond_with(@lecture, action: :show)
  end

  def duplicate
    lecture = @lecture.dup
    lecture.students = @lecture.students
    @lecture.lecture_staffs.map do |ls|
      lecture.lecture_staffs.build(staff_id: ls.staff_id, work_kind_id: ls.work_kind_id, start_time: ls.start_time, finish_time: ls.finish_time)
    end
    lecture.confirmed = :notyet
    @lecture = lecture
    render :new
  end

  def confirm_lecture
    ids = params[:lecture_ids].split(',')
    @lectures = Lecture.with_deleted.where(id: ids)
    days = params[:days] if params[:days].present?

    respond_with(@lectures, location: days)
  end

  def confirm_klass_subject
    ids = params[:lecture_ids].split(',')
    @lectures = Lecture.with_deleted.where(id: ids)

    respond_with(@lectures)
  end

  def duplicate_all
    lectures_ids = params[:lecture_ids].split(',')

    ids = []
    Lecture.transaction do
      new_lectures = lectures_ids.map do |lectures_id|
        lecture = Lecture.with_deleted.find(lectures_id)
        lecture.duplicate_after params[:days].to_i.days
      end
      ids = new_lectures.map(&:id) unless new_lectures.include?(nil)
    end
    flash[:notice] = "#{ids.count}件の#{Lecture.model_name.human}を複製しました。"
    redirect_to action: 'index', q: { id_eq_any: ids }
  end

  def duplicate_klass_subject
    lectures_ids = params[:lecture_ids].split(',')
    remain_lectures = params[:remain_lectures].to_i

    Lecture.transaction do
      (1..remain_lectures).step(lectures_ids.count).each.with_index(1) do |remain_lecture, i|
        lectures_ids.each_with_index do |lectures_id, j|
          break if (remain_lecture + j) > remain_lectures

          lecture = Lecture.with_deleted.find(lectures_id)
          lecture.duplicate_after((i * 7).days)
        end
      end
    end

    lecture = Lecture.with_deleted.find(lectures_ids[0])
    klass_subject_id = lecture.klass_subject_id

    flash[:notice] = "#{remain_lectures}件の#{Lecture.model_name.human}を作成しました。"
    redirect_to controller: 'klass_subjects', action: 'show', id: klass_subject_id
  end

  def cancel
    @lecture.canceled_status = params[:canceled_status]
    begin
      @lecture.cancel!(@lecture.canceled_status)
      flash[:notice] = t('controllers.lectures.cancel.flash.notice')
    rescue StandardError
      flash[:alert] = t('controllers.lectures.cancel.flash.alert')
    end
    redirect_to @lecture
  end

  def approve
    if @lecture.approve && @lecture.save
      flash[:notice] = t('controllers.lectures.approve.flash.notice')
    else
      flash[:alert] = t('controllers.lectures.approve.flash.alert')
    end
    redirect_back(fallback_location: :index)
  end

  def unapprove
    if @lecture.unapprove && @lecture.save
      flash[:notice] = t('controllers.lectures.unapprove.flash.notice')
    else
      flash[:alert] = t('controllers.lectures.unapprove.flash.alert')
    end
    redirect_back(fallback_location: :index)
  end

  def back_confirmed
    if @lecture.back_confirmed && @lecture.save
      flash[:notice] = t('controllers.lectures.back_confirmed.flash.notice')
    else
      flash[:alert] = t('controllers.lectures.back_confirmed.flash.alert')
    end
    redirect_back(fallback_location: :index)
  end

  def icalendar
    staff = StaffAuth.check_by_param!(params[:staff_id] || current_user.staff.id, params[:auth])
    from = Time.zone.today
    to = 1.month.since(from)
    lectures = Lecture.lecture_range_overlaps(from, to).includes(:lecture_staffs).where(lecture_staffs: { staff_id: staff.id }, canceled_status: nil)

    calendar = ical(lectures)
    headers['Content-Type'] = 'text/calendar; charset=UTF-8'
    render plain: calendar.to_ical
  end

  def change_request_for_vip
    @lecture.tag_list.add('時間変更中')
    begin
      @lecture.save!
      flash[:notice] = '授業時間変更申請しました。'
    rescue StandardError
      flash[:alert] = '授業時間変更申請に失敗しました。'
    end

    redirect_back(fallback_location: lecture_path(@lecture))
  end

  private

  def ical(lectures)
    calendar = ::Icalendar::Calendar.new
    calendar.timezone do |t|
      t.tzid = 'Asia/Tokyo'
      t.standard do |s|
        s.tzoffsetfrom = '+0900'
        s.tzoffsetto   = '+0900'
        s.tzname       = 'JST'
        s.dtstart      = '19700101T000000'
      end
    end

    calendar.append_custom_property('X-WR-CALNAME;VALUE=TEXT', '講義カレンダー')

    lectures.find_each do |lect|
      event = ::Icalendar::Event.new
      event.created = lect.created_at.utc if lect.created_at.present?
      event.description = lect.description
      event.dtstart = Icalendar::Values::DateTime.new lect.start_time
      event.dtend = Icalendar::Values::DateTime.new lect.finish_time
      event.last_modified = lect.updated_at.utc
      event.summary = lect.name
      event.uid = lect.id.to_s
      event.url = lecture_url(lect)
      calendar.add_event(event)
    end
    calendar.publish
    calendar
  end

  def set_lecture
    @lecture = Lecture.with_deleted.find(params[:id])
  end

  def init_lecture
    attributes = params[:lecture].blank? ? {} : lecture_params
    @lecture = Lecture.new attributes
  end

  def edit_lecture
    set_lecture
    return if params[:lecture].blank?

    @lecture.attributes = lecture_params
  end

  def lecture_params
    params.require(:lecture).permit!
  end

  def klass_ransack
    Klass.current.ransack(params[:r])
  end

  def staff_ransack
    Staff.ransack(params[:r])
  end

  def lectures_for_klasses(start_date, end_date, options = {})
    lectures = Lecture.ransack(
      {
        start_time_gteq: start_date,
        start_time_lt: end_date
      }.merge(options)
    ).result
                      .joins(:klass_subject)
                      .includes(taggings: :tag)
                      .eager_load(:subject, :lecture_staffs, klass_subject: %i[klass sharing_klasses shared_klass_klass_subjects])

    lectures.map do |lect|
      lect.klass_subject.klasses.map do |klass|
        staff_name = lect.lecture_staffs.map(&:staff).compact.map(&:name).join(',')
        {
          key: "#{lect.id}:#{klass.id}",
          klass_id: klass.id,
          klass_name: klass.name,
          subject_name: lect.subject&.name,
          staff_name: staff_name,
          name: klass == lect.klass_subject.klass ? lect.name : "#{lect.name} (共同 #{lect.klass_subject.klass.name})"
        }.merge(lect.attributes.slice('id', 'canceled_status', 'start_time', 'finish_time'))
      end
    end.flatten
  end

  def lectures_for_staffs(start_date, end_date, options = {})
    scope_lecture = Lecture.ransack({
      start_time_gteq: start_date,
      start_time_lt: end_date
    }.merge(options)).result.left_outer_joins(:subject, :reserve, klass_subject: %i[klass])
    LectureStaff.all.joins(:staff).joins(:lecture)
                .merge(scope_lecture)
                .select('lecture_staffs.id as lsid, lectures.*
                , staffs.id AS staff_id
                , staffs.name AS staff_name
                , klasses.name AS klass_name
                , klasses.id AS klass_id
                , lectures.canceled_status AS canceled_status
                , reserves.id AS reserve_id
                , subjects.personal AS subject_personal
                , subjects.name AS subject_name')

    # .select('lectures.*, klasses.name AS staff_name, klasses.id AS staff_id, subjects.name AS subject_name')
    # .left_outer_joins(:subject, :staffs, { klass_subject: %i[klass] })
  end
end
# rubocop:enable Metrics/ClassLength
