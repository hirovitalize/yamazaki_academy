# frozen_string_literal: true

class KlassSubjectsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_klass_subject, only: %i[show destroy fix unfix delete_lectures]
  before_action :init_klass_subject, only: %i[new create]
  before_action :edit_klass_subject, only: %i[edit update]
  before_action -> { check_authorize(@klass_subject, controller_name) }, only: %i[new create edit update destroy fix unfix delete_lectures]

  # GET /klass_subjects
  def index
    @q = KlassSubject.all.order(id: :desc).includes(:klass, :subject, :staff, :sharing_klasses, :shared_klass_klass_subjects).ransack(params[:q])
    @klass_subjects = @q.result.page(params[:page])
    respond_with(@klass_subjects)
  end

  # GET /klass_subjects/1
  def show
    respond_with(@klass_subject)
  end

  # GET /klass_subjects/new
  def new
    respond_with(@klass_subject)
  end

  # GET /klass_subjects/1/edit
  def edit
    respond_with(@klass_subject)
  end

  # POST /klass_subjects
  def create
    @klass_subject.save
    respond_with(@klass_subject)
  end

  # PATCH/PUT /klass_subjects/1
  def update
    @klass_subject.save
    respond_with(@klass_subject)
  end

  # DELETE /klass_subjects/1
  def destroy
    @klass_subject.destroy
    respond_with(@klass_subject, action: :show)
  end

  def delete_lectures
    begin
      ActiveRecord::Base.transaction do
        @klass_subject.lectures.map do |lecture|
          next if lecture.start_time <= Time.zone.now

          lecture.destroy!
        end
      end
      flash[:notice] = t('controllers.klass_subjects.delete_lectures.flash.notice')
    rescue StandardError
      flash[:alert] = t('controllers.klass_subjects.delete_lectures.flash.alert')
    end
    respond_with(@klass_subject, action: :show)
  end

  def fix
    @klass_subject.fixed = true
    begin
      @klass_subject.save!
      flash[:notice] = t('controllers.klass_subjects.fix.flash.notice')
    rescue StandardError
      flash[:alert] = t('controllers.klass_subjects.fix.flash.alert')
    end
    respond_with(@klass_subject)
  end

  def unfix
    @klass_subject.fixed = false
    begin
      @klass_subject.save!
      flash[:notice] = t('controllers.klass_subjects.unfix.flash.notice')
    rescue StandardError
      flash[:alert] = t('controllers.klass_subjects.unfix.flash.alert')
    end
    respond_with(@klass_subject)
  end

  private

  def set_klass_subject
    @klass_subject = KlassSubject.with_deleted.find(params[:id])
  end

  def init_klass_subject
    attributes = params[:klass_subject].blank? ? {} : klass_subject_params
    @klass_subject = KlassSubject.new attributes
  end

  def edit_klass_subject
    set_klass_subject
    return if params[:klass_subject].blank?

    @klass_subject.attributes = klass_subject_params
  end

  def klass_subject_params
    params.require(:klass_subject).permit!
  end
end
