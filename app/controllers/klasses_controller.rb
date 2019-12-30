# frozen_string_literal: true

class KlassesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_klass, only: %i[show destroy bulk_klass_subjects curriculum]
  before_action :init_klass, only: %i[new create]
  before_action :edit_klass, only: %i[edit update duplicate]
  before_action -> { check_authorize(@klass, controller_name) }, only: %i[new create edit update destroy duplicate]

  # GET /klasses
  def index
    @q = Klass.all.order(id: :desc).ransack(params[:q])
    @klasses = @q.result(distinct: true).page(params[:page]).includes(:klass_subjects, area: :province)
    respond_with(@klasses)
  end

  # GET /klasses/1
  def show
    respond_with(@klass)
  end

  # GET /klasses/1/curriculum
  def curriculum
    render :curriculum, layout: 'print'
  end

  # GET /klasses/1/curriculum_schedule
  def curriculum_schedule
    klass_subject_ids = KlassSubject.where(klass_id: params[:id]).pluck(:id) +
                        SharedKlassKlassSubject.where(klass_id: params[:id]).pluck(:klass_subject_id)
    lectures = Lecture.ransack(
      start_time_gteq: params[:start_date],
      start_time_lt: params[:end_date],
      klass_subject_id_in: klass_subject_ids
    )
                      .result
                      .left_outer_joins(:subject, :staffs, :klass_subject)
                      .includes(taggings: :tag)
                      .select('lectures.*, subjects.name AS subject_name, group_concat(distinct staffs.name) AS staff_names')
                      .group('id')
                      .uniq

    respond_with(lectures)
  end

  # GET /klasses/new
  def new
    respond_with(@klass)
  end

  def duplicate
    @klass = @klass.dup
    render :new
  end

  # GET /klasses/1/edit
  def edit
    respond_with(@klass)
  end

  # POST /klasses
  def create
    @klass.save
    respond_with(@klass)
  end

  # PATCH/PUT /klasses/1
  def update
    ActiveRecord::Base.transaction do
      @klass.change_lectures_name if @klass.klass_subjects.present?
      @klass.save
    end
    respond_with(@klass)
  end

  # DELETE /klasses/1
  def destroy
    @klass.destroy
    respond_with(@klass, action: :show)
  end

  def bulk_klass_subjects
    Klass.transaction do
      count = 0
      @klass.klass_template.subjects.map do |subject|
        next if @klass.klass_subjects.any? { |ks| ks.subject == subject }

        @klass.klass_subjects.build(
          subject: subject,
          lecture_num: @klass.lecture_num,
          interval: @klass.interval
        )
        count += 1
      end

      if @klass.save
        flash[:notice] = "#{count}件の#{KlassSubject.model_name.human}を生成しました"
      else
        flash[:alert] = "#{KlassSubject.model_name.human}#{t('controllers.klasses.bulk_klass_subjects.flash.alert')}"
      end
    end
    redirect_back(fallback_location: klass_path(@klass))
  end

  private

  def set_klass
    @klass = Klass.with_deleted.find(params[:id])
  end

  def init_klass
    attributes = params[:klass].blank? ? {} : klass_params
    @klass = Klass.new attributes
  end

  def edit_klass
    set_klass
    return if params[:klass].blank?

    @klass.attributes = klass_params
  end

  def klass_params
    params.require(:klass).permit!
  end
end
