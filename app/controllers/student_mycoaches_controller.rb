# frozen_string_literal: true

class StudentMycoachesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_mycoach, only: %i[show destroy lock unlock]
  before_action :edit_student_mycoach, only: %i[edit update]
  before_action -> { check_authorize(@student_mycoach, controller_name) }, only: %i[edit update destroy index show lock unlock]

  # GET /student_mycoaches
  def index
    @q = StudentMycoach.all.includes(:student).order(id: :desc).ransack(params[:q])
    @student_mycoaches = @q.result.page(params[:page])
    respond_with(@student_mycoaches)
  end

  # GET /student_mycoaches/1
  def show
    respond_with(@student_mycoach)
  end

  # GET /student_mycoaches/1/edit
  def edit
    respond_with(@student_mycoach)
  end

  # PATCH/PUT /student_mycoaches/1
  def update
    @student_mycoach.save
    respond_with(@student_mycoach)
  end

  # DELETE /student_mycoaches/1
  def destroy
    @student_mycoach.destroy
    respond_with(@student_mycoach, action: :show)
  end

  def lock
    @student_mycoach.lock_access!(send_instructions: false)
    flash[:notice] = t('controllers.student_mycoaches.lock.flash.notice')
    render :show
  end

  def unlock
    @student_mycoach.unlock_access!
    flash[:notice] = t('controllers.student_mycoaches.unlock.flash.notice')
    render :show
  end

  private

  def set_student_mycoach
    @student_mycoach = StudentMycoach.with_deleted.find(params[:id])
  end

  def edit_student_mycoach
    set_student_mycoach
    return if params[:student_mycoach].blank?

    @student_mycoach.attributes = student_mycoach_params
  end

  def student_mycoach_params
    params.require(:student_mycoach).permit!
  end
end
