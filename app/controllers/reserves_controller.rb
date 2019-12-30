# frozen_string_literal: true

class ReservesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_reserve, only: %i[show destroy]
  before_action :init_reserve, only: %i[new create]
  before_action :edit_reserve, only: %i[edit update]
  before_action -> { check_authorize(@reserve, controller_name) }, only: %i[new create edit update destroy]

  # GET /reserves
  def index
    @q = Reserve.all.order(id: :desc).ransack(params[:q])
    @reserves = @q.result.page(params[:page]).includes(:lecture, room: :building)
    respond_with(@reserves)
  end

  # GET /index_calendar
  # 読み取り専用画面
  def index_calendar
    @start_date = params[:start_date].presence || Time.zone.today
    @end_date = params[:end_date].presence || (Time.zone.parse(@start_date.to_s) + 1.day)

    @reserves = reserves(@start_date, @end_date)

    # params[:r]
    @r = room_ransack
    @room_ids = @r.result.ids.uniq

    gon.date = @start_date

    respond_with(@reserves)
  end

  # GET /calendar
  def calendar
    @start_date = params[:start_date].presence || Time.zone.today
    @end_date = params[:end_date].presence || (Time.zone.parse(@start_date.to_s) + 1.day)

    @reserves = reserves(@start_date, @end_date)

    # params[:r]
    @r = room_ransack
    @room_ids = @r.result.ids.uniq

    # params[:l]
    @l = lecture_ransack(@start_date, @end_date)
    @lectures = @l.result.uniq

    gon.date = @start_date
    respond_with(@reserves)
  end

  # GET /reserves/1
  def show
    respond_with(@reserve)
  end

  # GET /reserves/new
  def new
    respond_with(@reserve)
  end

  # GET /reserves/1/edit
  def edit
    respond_with(@reserve)
  end

  # POST /reserves
  def create
    @reserve.save(context: :form)
    respond_with(@reserve)
  end

  # PATCH/PUT /reserves/1
  def update
    @reserve.save(context: :form)
    respond_with(@reserve)
  end

  # DELETE /reserves/1
  def destroy
    @reserve.destroy
    respond_with(@reserve, action: :show)
  end

  def rooms_for_calendar
    rooms = Room
            .ransack(id_in: params[:ids].split(','))
            .result
            .left_outer_joins(:building)
            .select(['rooms.*',
                     'buildings.name AS buildings_name'].join(','))
            .uniq
    respond_with rooms
  end

  private

  def room_ransack
    Room.ransack(params[:r])
  end

  def lecture_ransack(start_date, end_date)
    q = params[:l].presence&.dup || {}
    q[:not_reserved] = true
    q[:not_canceled] = true
    q[:start_time_gteq] = start_date
    q[:start_time_lt] = end_date

    Lecture.ransack(q)
  end

  def reserves(start_date, end_date)
    Reserve
      .ransack(start_time_gteq: start_date, start_time_lt: end_date)
      .result
      .left_outer_joins(lecture: [:subject, { klass_subject: %i[klass] }])
      .select([
        'reserves.*',
        'lectures.name AS lecture_name',
        'time_changeable',
        'klasses.name AS klass_name',
        'subjects.name AS subject_name',
        'subjects.personal AS subject_pesonal'
      ].join(','))
      .uniq
  end

  def set_reserve
    @reserve = Reserve.with_deleted.find(params[:id])
  end

  def init_reserve
    attributes = params[:reserve].blank? ? {} : reserve_params
    @reserve = Reserve.new attributes
  end

  def edit_reserve
    set_reserve
    return if params[:reserve].blank?

    @reserve.attributes = reserve_params
  end

  def reserve_params
    params.require(:reserve).permit!
  end
end
